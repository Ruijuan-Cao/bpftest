 #include <linux/bpf.h>
#include <sys/resource.h>

#include <signal.h>
#include <locale.h>
#include <unistd.h> //sleep

#include <pthread.h>
#include <poll.h>

#include <arpa/inet.h>
#include <net/if.h>
#include <linux/if_ether.h>
#include <linux/ip.h>
#include <linux/ipv6.h>
#include <linux/icmpv6.h>

#include "common.h"
#include "operation.h"

int opt_timeout = 1000;
extern enum benchmark_type opt_bench;

//poller dump_stats with period
static void *poller(void *arg)
{
	(void)arg;
	while (1){
		sleep(opt_interval);
		dump_stats();
		print_stats_map_info();

	}
	return NULL;
}

//poller print stats map info with period
//poller dump_stats with period
static void *poller_stats(void *arg)
{
	(void)arg;
	while (1){
		sleep(1);
		print_stats_map_info();
	}
	return NULL;
}

//rx drop function
static void rx_drop(struct xsk_socket_info *xsk, struct pollfd *fds){
	//printf("----rx_drop----\n");
	//get the recvd packet number
	u32 idx_rx = 0, idx_fq = 0;
	unsigned int recvd = xsk_ring_cons__peek(&xsk->rx, BATCH_SIZE, &idx_rx);
	int ret;				

	//printf("recvd=%d\n", recvd);
	//if not recv, wakeup the umem, then wait using poll mode
	if (!recvd) {
		if (xsk_ring_prod__needs_wakeup(&xsk->umem->fq))
			ret = poll(fds, xsk_index, opt_timeout);
		return;
	}

	//if recv, then reserve space(recvd data's) in umem
	ret = xsk_ring_prod__reserve(&xsk->umem->fq, recvd, &idx_fq);

	printf("ret=%d\n", ret);
	while(ret != recvd){
		if (ret < 0)
			exit_with_error(-ret);
		if (xsk_ring_prod__needs_wakeup(&xsk->umem->fq))
			ret = poll(fds, xsk_index, opt_timeout);
		ret = xsk_ring_prod__reserve(&xsk->umem->fq, recvd, &idx_fq);
	}
	printf("recvd=%d, ret=%d\n", recvd, ret);
	//process the recved data
	for (int i = 0; i < recvd; ++i){
		//get addr、len from rx ring
		u64 addr = xsk_ring_cons__rx_desc(&xsk->rx, idx_rx)->addr;
		u32 len = xsk_ring_cons__rx_desc(&xsk->rx, idx_rx++)->len;

		//save orig addr to a temp variable（orig）
		u64 orig = xsk_umem__extract_addr(addr);

		//add umem's offset to addr,get the real addr
		addr = xsk_umem__add_offset_to_addr(addr);

		//get data from umem(real addr)
		char *pkt = xsk_umem__get_data(xsk->umem->area, addr);
		//dump recvd data in hex mode
		hex_dump(pkt, len, addr);
		//push original addr to umem's fill ring
		*xsk_ring_prod__fill_addr(&xsk->umem->fq, idx_fq++) = orig;
	}	

	//submit umem's fq
	xsk_ring_prod__submit(&xsk->umem->fq, recvd);
	//release socket's rx
	xsk_ring_cons__release(&xsk->rx, recvd);	
	//update the xsk's rx packet number
	xsk->rx_npkts += recvd;
}

//rx drop only
static void rx_drop_all(){
	printf("----rx_drop_all----\n");

	struct pollfd fds[MAX_SOCKS] = {};

	for (int i = 0; i < xsk_index; ++i){
		fds[i].fd = xsk_socket__fd(xsks[i]->xsk);
		fds[i].events = POLLIN;
	}

	while(1){
		if (opt_poll){
			int ret = poll(fds, xsk_index, opt_timeout);
			if (ret <= 0)
				continue;
		}

		for (int i = 0; i < xsk_index; ++i)
			rx_drop(xsks[i], fds);
	}
}

static void tx_only(struct xsk_socket_info *xsk, u32 frame_nb)
{
	u32 idx;
	if (xsk_ring_prod__reserve(&xsk->tx, BATCH_SIZE, &idx) == BATCH_SIZE){
		for (int i = 0; i < BATCH_SIZE; ++i){
			//set the tx ring
			xsk_ring_prod__tx_desc(&xsk->tx, idx + i)->addr = (frame_nb + i) << XSK_UMEM__DEFAULT_FRAME_SHIFT;
			xsk_ring_prod__tx_desc(&xsk->tx, idx + i)->len = sizeof(pkt_data) - 1;
		}

		xsk_ring_prod__submit(&xsk->tx, BATCH_SIZE);
		xsk->outstanding_tx += BATCH_SIZE;

		frame_nb += BATCH_SIZE;
		frame_nb %= FRAME_NUM;
	}

	//tx
	if (!xsk->outstanding_tx)
		return;

	//wakeup tx
	if (!opt_need_wakeup || xsk_ring_prod__needs_wakeup(&xsk->tx))
		kick_tx(xsk);

	//get complete
	int complete = xsk_ring_cons__peek(&xsk->umem->cq, BATCH_SIZE, &idx);
	if (complete > 0){
		xsk_ring_cons__release(&xsk->umem->cq, complete);
		xsk->outstanding_tx -= complete;
		xsk->tx_npkts += complete;
	}
}

//tx only
static void tx_only_all(){
	printf("----tx_only_all----\n");

	struct pollfd fds[MAX_SOCKS] = {};
	u32 frame_nb[MAX_SOCKS] = {};

	//why only 0
	for (int i = 0; i < xsk_index; ++i){
		fds[0].fd = xsk_socket__fd(xsks[i]->xsk);
		fds[0].events = POLLOUT;
	}

	while(1){
		if (opt_poll){
			int ret = poll(fds, xsk_index, opt_timeout);
			if (ret <= 0)
				continue;
			if (!(fds[0].revents & POLLOUT))
				continue;
		}

		for (int i = 0; i < xsk_index; ++i)
			tx_only(xsks[i], frame_nb[i]);
	}
}

//process_packet, then echo IPv6 ICMP
static bool process_packet_l2fwd(struct xsk_socket_info *xsk, uint64_t addr, uint32_t len)
{
	//get packet
	char *pkt = xsk_umem__get_data(xsk->umem->area, addr);	

	//get ipv6 info
	struct ethhdr *eth = (struct ethhdr *) pkt;
	
	//get ip addr
	for(int i = 0;i < 6; i++){
		printf("---%d---\n", i);
		printf("Source host:%s, %d\n",eth->h_source, eth->h_source[i]);
        	printf("Dest host:%s, %d\n", eth->h_dest, eth->h_dest[i]);
	}

	struct ipv6hdr *ipv6 = (struct ipv6hdr *) (eth + 1);
	struct icmp6hdr *icmp = (struct icmp6hdr *) (ipv6 + 1);

	//check
	//if (ntohs(eth->h_proto) == ETH_P_IP)
		printf("--------------------h_proto=%x, len=%d\n", ntohs(eth->h_proto), len);
	//else
	//	printf("----recv--%d-----%d\n", len, ntohs(eth->h_proto));

	if (ntohs(eth->h_proto) != ETH_P_IP ||
		    len < (sizeof(*eth) + sizeof(*ipv6) + sizeof(*icmp)) ||
		    ipv6->nexthdr != IPPROTO_ICMPV6 ||
		    icmp->icmp6_type != ICMPV6_ECHO_REQUEST)
				return false;
	
	//swap dest and source mac
	char tmp_mac[ETH_ALEN];
	memcpy(tmp_mac, eth->h_dest, ETH_ALEN);
	memcpy(eth->h_dest, eth->h_source, ETH_ALEN);
	memcpy(eth->h_source, tmp_mac, ETH_ALEN);

	//swap ip
	struct in6_addr tmp_ip;
	memcpy(&tmp_ip, &ipv6->saddr, sizeof(tmp_ip));
	memcpy(&ipv6->saddr, &ipv6->daddr, sizeof(tmp_ip));
	memcpy(&ipv6->daddr, &tmp_ip, sizeof(tmp_ip));

	icmp->icmp6_type = ICMPV6_ECHO_REPLY;
	csum_replace2(&icmp->icmp6_cksum,
		htons(ICMPV6_ECHO_REQUEST << 8),
	    htons(ICMPV6_ECHO_REPLY << 8));

	//send back, reserve tx space
	u32 tx_idx = 0; 
	int ret = 0;
	ret = xsk_ring_prod__reserve(&xsk->tx, 1, &tx_idx);
	if(ret != 1)
		return false;

	//fill addr to tx 
	xsk_ring_prod__tx_desc(&xsk->tx, tx_idx)->addr = addr;
	xsk_ring_prod__tx_desc(&xsk->tx, tx_idx)->len = len;
	xsk_ring_prod__submit(&xsk->tx, 1);
	xsk->outstanding_tx++;

	xsk->tx_npkts++;
	return true;
}

static void complete_tx(struct xsk_socket_info *xsk)
{
	//complete tx process
	u32 idx_cq = 0;
	//tx
	if (!xsk->outstanding_tx)
		return;

	//wakeup tx
	if (!opt_need_wakeup || xsk_ring_prod__needs_wakeup(&xsk->tx))
		kick_tx(xsk);

	//get completed
	int completed = xsk_ring_cons__peek(&xsk->umem->cq, XSK_RING_CONS__DEFAULT_NUM_DESCS, &idx_cq);
	if (completed > 0){
		for (int i = 0; i < completed; i++)
			xsk_free_umem_frame(xsk, *xsk_ring_cons__comp_addr(&xsk->umem->cq,idx_cq++));
		xsk_ring_cons__release(&xsk->umem->cq, completed);
	}
}

//recv, then send
static void l2fwd(struct xsk_socket_info *xsk, struct pollfd *fds)
{
	u32 idx_rx = 0, idx_fq = 0;

	//recv
	int recvd = xsk_ring_cons__peek(&xsk->rx, BATCH_SIZE, &idx_rx);
	if (!recvd)
		return;

	//Stuff the ring with as much frames as possible 
	int stock_frames = xsk_prod_nb_free(&xsk->umem->fq, xsk->umem_frame_free);
	if (stock_frames > 0){
		//get space
		int ret = xsk_ring_prod__reserve(&xsk->umem->fq, stock_frames, &idx_fq);
		while(ret != stock_frames)
			ret = xsk_ring_prod__reserve(&xsk->umem->fq, recvd, &idx_fq);

		//FILL RING
		for (int i = 0; i < stock_frames; ++i)
			*xsk_ring_prod__fill_addr(&xsk->umem->fq, idx_fq++) = xsk_alloc_umem_frame(xsk);
		
		xsk_ring_prod__submit(&xsk->umem->fq, stock_frames);
	}

	//process packets
	for (int i = 0; i < recvd; ++i){
		//get addr、len from rx ring
		u64 addr = xsk_ring_cons__rx_desc(&xsk->rx, idx_rx)->addr;
		u32 len = xsk_ring_cons__rx_desc(&xsk->rx, idx_rx++)->len;

		if(!process_packet_l2fwd(xsk, addr, len))		//drop directly
			xsk_free_umem_frame(xsk, addr);
	}

	//release socket's rx
	xsk_ring_cons__release(&xsk->rx, recvd);	
	//update the xsk's rx packet number
	xsk->rx_npkts += recvd;

	//Do we need to wake up the kernel for transmission 
	complete_tx(xsk);
}

//forward
static void l2fwd_all(){
	printf("----l2fwd_all----\n");

	struct pollfd fds[MAX_SOCKS] = {};

	for (int i = 0; i < xsk_index; ++i){
		fds[i].fd = xsk_socket__fd(xsks[i]->xsk);
		fds[i].events = POLLIN | POLLOUT;
	}

	while(1){
		if (opt_poll){
			int ret = poll(fds, xsk_index, opt_timeout);
			if (ret <= 0)
				continue;
		}

		for (int i = 0; i < xsk_index; ++i)
			l2fwd(xsks[i], fds);
	}
}


int main(int argc, char **argv)
{
	struct rlimit r = {RLIM_INFINITY, RLIM_INFINITY};
	struct xdp_config cfg = {
		.ifindex = -1,
		.do_unload = false,
		.filename = "",
		.progsec = "filter"
	};

	bool rx = false, tx = false;
	struct bpf_object *bpf_obj;

	//command line option for changing config
	printf("start command line\n");
	parse_command_line(argc, argv, &cfg);
	printf("after command line\n");
	
	if (setrlimit(RLIMIT_MEMLOCK, &r)) {
		fprintf(stderr, "ERROR: setrlimit(RLIMIT_MEMLOCK) \"%s\"\n",
			strerror(errno));
		exit(EXIT_FAILURE);
	}
	
	// Unload XDP program if requested 
	//if (cfg.do_unload)
	//	return detach_bpf_off_xdp(cfg.ifindex, cfg.xdp_flags);
	//printf("after Unload\n");
	
	//if(opt_xsks_num > 1){
		load_xdp_program(argv, &bpf_obj);
		printf("after load_bpf_program\n");
	//}	

	//load bpf prog
	//bpf_obj = load_bpf_and_xdp_attach(&cfg);

	//config & create umem
	struct xsk_umem_info *umem = xsk_configure_umem();
	printf("after xsk_configure_umem\n");
	//rx or tx
	if (opt_bench == BENCH_RXDROP || opt_bench == BENCH_L2FWD) {
		rx = true;
		xsk_populate_fill_ring(umem);
	}
	if (opt_bench == BENCH_L2FWD || opt_bench == BENCH_TXONLY)
		tx = true;

	//config & create socket
	for(int i = 0; i < opt_xsks_num; i++)
		xsks[xsk_index++] = xsk_configure_socket(umem, rx, tx);
	printf("success to config socket\n");

	if (opt_bench == BENCH_TXONLY)
		for (int i = 0; i < FRAME_NUM; ++i)
			gen_eth_frame(umem, i * opt_xsk_frame_size);

	if (opt_xsks_num > 1 && opt_bench != BENCH_TXONLY)
		configure_bpf_map(bpf_obj);
	
	//stats map
	configure_status_map(bpf_obj);

	signal(SIGINT, normal_exit);
	signal(SIGTERM, normal_exit);
	signal(SIGABRT, normal_exit);

	setlocale(LC_ALL, "");

	pthread_t pt;
	int ret = pthread_create(&pt, NULL, poller, NULL);
	if (ret)
		exit_with_error(ret);

/*
	pthread_t pt2;
	int ret2 = pthread_create(&pt2, NULL, poller_stats, NULL);
	if (ret2)
		exit_with_error(ret2);
*/
	pre_time = get_nsecs();

	if (opt_bench == BENCH_RXDROP)
		rx_drop_all();
	else if (opt_bench == BENCH_TXONLY)
		tx_only_all();
	else
		l2fwd_all();
	
	return 0;
}
