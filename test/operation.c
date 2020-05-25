#include "operation.h"

#include <libgen.h>
#include <net/if.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <linux/if_xdp.h>

enum benchmark_type opt_bench = BENCH_RXDROP;
int opt_xsk_frame_size = XSK_UMEM__DEFAULT_FRAME_SIZE;

bool opt_need_wakeup = true;

int opt_xsks_num = 1;
int opt_poll;
int opt_interval = 1;

unsigned long pre_time;

int xsk_index = 0;
struct xsk_socket_info *xsks[MAX_SOCKS];

const char *opt_if = "";
int opt_ifindex;
int opt_queue;

int opt_unaligned_chunks;
int opt_umem_flags = XSK_UMEM__DEFAULT_FLAGS;
int opt_mmap_flags = 0;

u32 opt_xdp_bind_flags;
u32 opt_xdp_flags = XDP_FLAGS_UPDATE_IF_NOEXIST;
char *opt_progsec;

u32 prog_id;

//stats_map
struct datarec *stats_rec;

void load_bpf_program(char **argv, struct bpf_object **bpf_obj){
	printf("----load xdp program----\n");

	//load bpf object
	struct bpf_prog_load_attr prog_load_attr = {
		.prog_type      = BPF_PROG_TYPE_XDP,
		.ifindex 		= opt_ifindex
	};
	char xdp_filename[256];
	int prog_fd;

	//snprintf(xdp_filename, sizeof(xdp_filename), "%s_kern.o", argv[0]);
	prog_load_attr.file = "test_kern.o";//xdp_filename;

	/* Use libbpf for extracting BPF byte-code from BPF-ELF object, and
	 * loading this into the kernel via bpf-syscall
	 */
	if (bpf_prog_load_xattr(&prog_load_attr, bpf_obj, &prog_fd)){
		fprintf(stderr, "ERR: loading BPF-OBJ file(%s) (%d): %s\n", xdp_filename, errno, strerror(-errno));
		exit(EXIT_FAILURE);
	}

	/* At this point: All XDP/BPF programs from the cfg->filename have been
	 * loaded into the kernel, and evaluated by the verifier. Only one of
	 * these gets attached to XDP hook, the others will get freed once this
	 * process exit.
	 */
	struct bpf_program *bpf_prog;
	if (!opt_progsec)
		// find a matching bpf prog by section name
		bpf_prog = bpf_object__find_program_by_title(*bpf_obj, opt_progsec);
	else
		// find the first program
		bpf_prog = bpf_program__next(NULL, *bpf_obj);

	if (!bpf_prog){
		fprintf(stderr, "ERR: couldn't find a program in ELF secion '%s'\n", opt_progsec);
		exit(EXIT_FAIL_BPF);
	}
	//get prog fd
	prog_fd = bpf_program__fd(bpf_prog);
		if (prog_fd <= 0) {
		fprintf(stderr, "ERR: bpf_program__fd failed\n");
		exit(EXIT_FAIL_BPF);
	}

	/* At this point: BPF-progs are (only) loaded by the kernel, and prog_fd
	 * is our select file-descriptor handle. Next step is attaching this FD
	 * to a kernel hook point, in this case XDP net_device link-level hook.
	 */
	if (bpf_set_link_xdp_fd(opt_ifindex, prog_fd, opt_xdp_flags) < 0) {
		fprintf(stderr, "ERROR: link set xdp fd failed\n");
		exit(EXIT_FAILURE);
	}
}

void remove_bpf_program(){
	printf("----remove xdp program----\n");
	u32 curr_prog_id = 0;

	if (bpf_get_link_xdp_id(opt_ifindex, &curr_prog_id, opt_xdp_flags)) {
		printf("bpf_get_link_xdp_id failed\n");
		exit(EXIT_FAILURE);
	}
	if (prog_id == curr_prog_id)
		bpf_set_link_xdp_fd(opt_ifindex, -1, opt_xdp_flags);
	else if (!curr_prog_id)
		printf("couldn't find a prog id on a given interface\n");
	else
		printf("program on interface changed, not removing\n");
}

int attach_bpf_off_xdp(int ifindex, u32 xdp_flags, int prog_fd){
	int err;

	/* libbpf provide the XDP net_device link-level hook attach helper */
	err = bpf_set_link_xdp_fd(ifindex, prog_fd, xdp_flags);
	if (err == -EEXIST && !(xdp_flags & XDP_FLAGS_UPDATE_IF_NOEXIST)) {
		/* Force mode didn't work, probably because a program of the
		 * opposite type is loaded. Let's unload that and try loading
		 * again.
		 */

		__u32 old_flags = xdp_flags;

		xdp_flags &= ~XDP_FLAGS_MODES;
		xdp_flags |= (old_flags & XDP_FLAGS_SKB_MODE) ? XDP_FLAGS_DRV_MODE : XDP_FLAGS_SKB_MODE;
		err = bpf_set_link_xdp_fd(ifindex, -1, xdp_flags);
		if (!err)
			err = bpf_set_link_xdp_fd(ifindex, prog_fd, old_flags);
	}

	if (err < 0) {
		fprintf(stderr, "ERR: "
			"ifindex(%d) link set xdp fd failed (%d): %s\n",
			ifindex, -err, strerror(-err));

		switch (-err) {
		case EBUSY:
		case EEXIST:
			fprintf(stderr, "Hint: XDP already loaded on device"
				" use --force to swap/replace\n");
			break;
		case EOPNOTSUPP:
			fprintf(stderr, "Hint: Native-XDP not supported"
				" use --skb-mode or --auto-mode\n");
			break;
		default:
			break;
		}
		return EXIT_FAIL_XDP;
	}

	return EXIT_OK;
}
int detach_bpf_off_xdp(int ifindex, u32 xdp_flags){
	int err;
	if ((err = bpf_set_link_xdp_fd(ifindex, -1, xdp_flags)) < 0) {
		fprintf(stderr, "ERR: link set xdp unload failed (err=%d):%s\n",
			err, strerror(-err));
		return EXIT_FAIL_XDP;
	}
	return 0;
}

struct xsk_umem_info *xsk_configure_umem(){
	printf("----xsk configure umem----\n");
	//umem config
	struct xsk_umem_config cfg = {
		.fill_size = XSK_RING_PROD__DEFAULT_NUM_DESCS,
		.comp_size = XSK_RING_PROD__DEFAULT_NUM_DESCS,
		.frame_size = opt_xsk_frame_size,
		.frame_headroom = XSK_UMEM__DEFAULT_FRAME_HEADROOM,
		.flags = opt_umem_flags,
	};
	//umem calloc
	struct xsk_umem_info *umem = calloc(1, sizeof(*umem));
	if (!umem)
		exit_with_error(errno);

	//umem area, mmap/munmap - map or unmap files or devices into memory
	void *umem_area = mmap(NULL, FRAME_NUM * opt_xsk_frame_size,
		    PROT_READ | PROT_WRITE,
		    MAP_PRIVATE | MAP_ANONYMOUS | opt_mmap_flags, -1, 0);
	if (umem_area == MAP_FAILED)
	{
		printf("mmap failed\n");
		exit_with_error(errno);		
	}

	//create umem
	int ret = xsk_umem__create(&umem->umem, umem_area, FRAME_NUM * opt_xsk_frame_size, &umem->fq, &umem->cq, &cfg);
	if (ret)
	 	exit_with_error(ret);

	 umem->area = umem_area;
	 return umem;
}
void xsk_populate_fill_ring(struct xsk_umem_info *umem)
{
	printf("----xsk xsk_populate_fill_ring----\n");
	int ret, i;
	u32 idx;

	ret = xsk_ring_prod__reserve(&umem->fq,
				     XSK_RING_PROD__DEFAULT_NUM_DESCS, &idx);
	if (ret != XSK_RING_PROD__DEFAULT_NUM_DESCS)
		exit_with_error(-ret);
	for (i = 0; i < XSK_RING_PROD__DEFAULT_NUM_DESCS; i++)
		*xsk_ring_prod__fill_addr(&umem->fq, idx++) =
			i * opt_xsk_frame_size;
	xsk_ring_prod__submit(&umem->fq, XSK_RING_PROD__DEFAULT_NUM_DESCS);
}
u64 xsk_alloc_umem_frame(struct xsk_socket_info *xsk){
	uint64_t frame;
	if (xsk->umem_frame_free == 0)
		return INVALID_UMEM_FRAME;

	frame = xsk->umem_frame_addr[--xsk->umem_frame_free];
	xsk->umem_frame_addr[xsk->umem_frame_free] = INVALID_UMEM_FRAME;
	return frame;
}

void xsk_free_umem_frame(struct xsk_socket_info *xsk, u64 frame){
	if(xsk->umem_frame_free < FRAME_NUM)
		xsk->umem_frame_addr[xsk->umem_frame_free++] = frame;
}

struct xsk_socket_info *xsk_configure_socket(struct xsk_umem_info *umem, bool rx, bool tx){
	printf("----xsk_configure_socket----\n");
	//config
	struct xsk_socket_config cfg;
	struct xsk_socket_info *xsk;
	struct xsk_ring_prod *txr;
	struct xsk_ring_cons *rxr;

	//xsk socket
	xsk = calloc(1, sizeof(*xsk));
	if (!xsk)
		exit_with_error(errno);
	xsk->umem = umem;

	//cfg
	cfg.rx_size = XSK_RING_CONS__DEFAULT_NUM_DESCS;
	cfg.tx_size = XSK_RING_PROD__DEFAULT_NUM_DESCS;
	if (opt_xsks_num > 1)
		cfg.libbpf_flags = XSK_LIBBPF_FLAGS__INHIBIT_PROG_LOAD;
	else
		cfg.libbpf_flags = 0;
	cfg.xdp_flags = opt_xdp_flags;
	cfg.bind_flags = opt_xdp_bind_flags;

	//rx-tx
	rxr = rx ? &xsk->rx : NULL;
	txr = tx ? &xsk->tx : NULL;

	//crate xsk
	int ret = xsk_socket__create(&xsk->xsk, opt_if, opt_queue, umem->umem, rxr, txr, &cfg);
	if(ret)
		exit_with_error(-ret);

	//get xdp id
	int xdpid = bpf_get_link_xdp_id(opt_ifindex, &prog_id, opt_xdp_flags);	
	if(xdpid)
		exit_with_error(-xdpid);

	/* Initialize umem frame allocation */
	for (int i = 0; i < FRAME_NUM; i++)
		xsk->umem_frame_addr[i] = i * opt_xsk_frame_size;

	xsk->umem_frame_free = FRAME_NUM;

	return xsk; 
}

void configure_bpf_map(struct bpf_object *bpf_obj){
	//bpf map
	struct bpf_map *map = bpf_object__find_map_by_name(bpf_obj, "bpf_pass_map");
	int pass_map = bpf_map__fd(map);
	if (pass_map < 0)
	{
		fprintf(stderr, "%s\n", strerror(pass_map));
		exit(EXIT_FAILURE);
	}

	for (int i = 0; i < xsk_index; ++i)
	{
		int fd = xsk_socket__fd(xsks[i]->xsk);
		int key = i;
		int ret = bpf_map_update_elem(pass_map, &key, &fd, 0);
		if (ret)
		{
			fprintf(stderr, "ERROR: bpf_map_update_elem %d\n", i);
			exit(EXIT_FAILURE);
		}
	}
}

//print addr and count
void configure_status_map(struct bpf_object *bpf_obj){
	//bpf stats map
	struct bpf_map *stats_map = bpf_object__find_map_by_name(bpf_obj, "bpf_stats_map");
	int stats_map_fd = bpf_map__fd(stats_map);
	if(stats_map < 0){
		fprintf(stderr, "%s\n", strerror(stats_map_fd));
		exit(EXIT_FAILURE);
	} 

	//get map info
	struct bpf_map_info *stats_map_info;
	__u32 info_len = sizeof(*stats_map_info);
	int err = bpf_obj_get_info_by_fd(stats_map_fd, stats_map_info, &info_len);
	if (err){
		fprintf(stderr, "%s\n", strerror(errno));
		exit(EXIT_FAILURE);
	}

	//print info
	__u32 key = XDP_PASS;
	if ((bpf_map_lookup_elem(stats_map_fd, &key, stats_rec)) != 0) {
		fprintf(stderr, "ERR: bpf_map_lookup_elem failed key:0x%X\n", key);
	}
}

//kick_tx, keep wake
void kick_tx(struct xsk_socket_info *xsk){
	int ret;

	ret = sendto(xsk_socket__fd(xsk->xsk), NULL, 0, MSG_DONTWAIT, NULL, 0);
	if (ret >= 0 || errno == ENOBUFS || errno == EAGAIN || errno == EBUSY)
		return;
	exit_with_error(errno);
}

void gen_eth_frame(struct xsk_umem_info *umem, u64 addr){
	memcpy(xsk_umem__get_data(umem->area, addr), pkt_data, sizeof(pkt_data) - 1);
	//return sizeof(pkt_data) - 1;
}

void usage(const char *prog){
	const char *str =
		"  Usage: %s [OPTIONS]\n"
		"  Options:\n"		
		"  -x, --progsec 	Set program section in kern.c\n"
		"  -r, --rxdrop		Discard all incoming packets (default)\n"
		"  -t, --txonly		Only send packets\n"
		"  -l, --l2fwd		MAC swap L2 forwarding\n"
		"  -i, --interface=n	Run on interface n\n"
		"  -q, --queue=n	Use queue n (default 0)\n"
		"  -p, --poll		Use poll syscall\n"
		"  -S, --xdp-skb=n	Use XDP skb-mod\n"
		"  -N, --xdp-native=n	Enforce XDP native mode\n"
		"  -n, --interval=n	Specify statistics update interval (default 1 sec).\n"
		"  -z, --zero-copy      Force zero-copy mode.\n"
		"  -c, --copy           Force copy mode.\n"
		"  -m, --no-need-wakeup Turn off use of driver need wakeup flag.\n"
		"  -f, --frame-size=n   Set the frame size (must be a power of two in aligned mode, default is %d).\n"
		"  -u, --unaligned	Enable unaligned chunk placement\n"
		"  -M, --shared-umem	Enable XDP_SHARED_UMEM\n"
		"  -F, --force		Force loading the XDP prog\n"
		"\n";
	fprintf(stderr, str, prog, XSK_UMEM__DEFAULT_FRAME_SIZE);
	exit(EXIT_FAILURE);
}

void print_benchmark(bool running){
	const char *bench_str = "INVALID";

	if (opt_bench == BENCH_RXDROP)
		bench_str = "rxdrop";
	else if (opt_bench == BENCH_TXONLY)
		bench_str = "txonly";
	else if (opt_bench == BENCH_L2FWD)
		bench_str = "l2fwd";

	printf("%s:%d %s ", opt_if, opt_queue, bench_str);
	if (opt_xdp_flags & XDP_FLAGS_SKB_MODE)
		printf("xdp-skb ");
	else if (opt_xdp_flags & XDP_FLAGS_DRV_MODE)
		printf("xdp-drv ");
	else
		printf("	");

	if (opt_poll)
		printf("poll() ");

	if (running) {
		printf("running...");
		fflush(stdout);
	}
}

//option
struct option long_options[] = {
	{"rxdrop", no_argument, 0, 'r'},
	{"txonly", no_argument, 0, 't'},
	{"l2fwd", no_argument, 0, 'l'},
	{"interface", required_argument, 0, 'i'},	
	{"progsec", required_argument, 0, 'x'},
	{"queue", required_argument, 0, 'q'},
	{"poll", no_argument, 0, 'p'},
	{"xdp-skb", no_argument, 0, 'S'},
	{"xdp-native", no_argument, 0, 'N'},
	{"interval", required_argument, 0, 'n'},
	{"zero-copy", no_argument, 0, 'z'},
	{"copy", no_argument, 0, 'c'},
	{"frame-size", required_argument, 0, 'f'},
	{"no-need-wakeup", no_argument, 0, 'm'},
	{"unaligned", no_argument, 0, 'u'},
	{"shared-umem", no_argument, 0, 'M'},
	{"force", no_argument, 0, 'F'},
	{0, 0, 0, 0}
};
void parse_command_line(int argc, char **argv, struct xdp_config *cfg){
	int option_index, c;

	for (;;) {
		c = getopt_long(argc, argv, "Frtli:x:q:psSNn:czf:muM",
				long_options, &option_index);
		if (c == -1)
			break;

		switch (c) {
		case 'x':
			opt_progsec = optarg;
			break;
		case 'r':
			opt_bench = BENCH_RXDROP;
			break;
		case 't':
			opt_bench = BENCH_TXONLY;
			break;
		case 'l':
			opt_bench = BENCH_L2FWD;
			break;
		case 'i':
			opt_if = optarg;
			break;
		case 'q':
			opt_queue = atoi(optarg);
			break;
		case 'p':
			opt_poll = 1;
			break;
		case 'S':
			opt_xdp_flags |= XDP_FLAGS_SKB_MODE;
			opt_xdp_bind_flags |= XDP_COPY;
			break;
		case 'N':
			opt_xdp_flags |= XDP_FLAGS_DRV_MODE;
			break;
		case 'n':
			opt_interval = atoi(optarg);
			break;
		case 'z':
			opt_xdp_bind_flags |= XDP_ZEROCOPY;
			break;
		case 'c':
			opt_xdp_bind_flags |= XDP_COPY;
			break;
		case 'u':
			opt_umem_flags |= XDP_UMEM_UNALIGNED_CHUNK_FLAG;
			opt_unaligned_chunks = 1;
			opt_mmap_flags = MAP_HUGETLB;
			break;
		case 'F':
			opt_xdp_flags &= ~XDP_FLAGS_UPDATE_IF_NOEXIST;
			break;
		case 'f':
			opt_xsk_frame_size = atoi(optarg);
			break;
		case 'm':
			opt_need_wakeup = false;
			opt_xdp_bind_flags &= ~XDP_USE_NEED_WAKEUP;
			break;
		case 'M':
			opt_xsks_num = MAX_SOCKS;
			break;
		default:
			usage(basename(argv[0]));
		}
	}

	printf("---if----%s\n", opt_if);
	opt_ifindex = if_nametoindex(opt_if);
	if (!opt_ifindex) {
		fprintf(stderr, "ERROR: interface \"%s\" does not exist\n",
			opt_if);
		usage(basename(argv[0]));
	}
	printf("if_nametoindex\n");

	cfg->ifindex = opt_ifindex;
 	cfg->xdp_flags = opt_xdp_flags;

	if ((opt_xsk_frame_size & (opt_xsk_frame_size - 1)) &&
	    !opt_unaligned_chunks) {
		fprintf(stderr, "--frame-size=%d is not a power of two\n",
			opt_xsk_frame_size);
		usage(basename(argv[0]));
	}
	printf("usage\n");
}

void dump_stats(){
	unsigned long now = get_nsecs();
	long dt = now - pre_time;
	int i;

	pre_time = now;

	for (i = 0; i < xsk_index && xsks[i]; i++) {
		char *fmt = "%-15s %'-11.0f %'-11lu\n";
		double rx_pps, tx_pps;

		rx_pps = (xsks[i]->rx_npkts - xsks[i]->pre_rx_npkts) *
			 1000000000. / dt;
		tx_pps = (xsks[i]->tx_npkts - xsks[i]->pre_tx_npkts) *
			 1000000000. / dt;

		printf("\n sock%d@", i);
		print_benchmark(false);
		printf("\n");

		printf("%-15s %-11s %-11s %-11.2f\n", "", "pps", "pkts",
		       dt / 1000000000.);
		printf(fmt, "rx", rx_pps, xsks[i]->rx_npkts);
		printf(fmt, "tx", tx_pps, xsks[i]->tx_npkts);

		xsks[i]->pre_rx_npkts = xsks[i]->rx_npkts;
		xsks[i]->pre_tx_npkts = xsks[i]->tx_npkts;
	}
}

void print_stats_map_info(){
	//print stats map info
	printf("stats_map----%d----%x\n", stats_rec->rx_packets, stats_rec->saddr);
}

void __exit_with_error(int error, const char *file, const char *func, int line){
	fprintf(stderr, "%s:%s:%i: errno: %d/\"%s\"\n", file, func,
		line, error, strerror(error));
	dump_stats();
	remove_bpf_program();
	exit(EXIT_FAILURE);
}

void normal_exit(int sig){
	printf("----normal_exit----\n");
	struct xsk_umem *umem = xsks[0]->umem->umem;
	int i;

	dump_stats();
	for (i = 0; i < xsk_index; i++)
		xsk_socket__delete(xsks[i]->xsk);
	xsk_umem__delete(umem);
	remove_bpf_program();

	exit(EXIT_SUCCESS);
}
