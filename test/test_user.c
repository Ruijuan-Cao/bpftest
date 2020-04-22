#include <errno.h>
#include <getopt.h>
#include <libgen.h>
#include <linux/bpf.h>
#include <linux/if_link.h>
#include <linux/if_xdp.h>
#include <sys/mman.h>
#include <sys/resource.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <stdio.h>
#include <stdlib.h>

#include <signal.h>
#include <locale.h>
#include <time.h>

#include <net/if.h>

#include <bpf/libbpf.h>
#include <bpf/xsk.h>
#include <bpf/bpf.h>

#include "common_defs.h"

#ifndef MAX_SOCKS
#define MAX_SOCKS 4
#endif


#define FRAME_NUM (4 * 1024)
#define BATCH_SIZE	64

typedef __u64 u64;
typedef __u32 u32;

enum benchmark_type {
	BENCH_RXDROP = 0,
	BENCH_TXONLY = 1,
	BENCH_L2FWD = 2,
};
static enum benchmark_type opt_bench = BENCH_RXDROP;

static int opt_xsk_frame_size = XSK_UMEM__DEFAULT_FRAME_SIZE;
static int frame_headroom = XSK_UMEM__DEFAULT_FRAME_HEADROOM;
static int opt_umem_flags = XSK_UMEM__DEFAULT_FLAGS;
static int opt_mmap_flags = 0;
static int opt_unaligned_chunks;

//static int opt_timeout = 1000;
static bool opt_need_wakeup = true;

static u32 opt_xdp_bind_flags;

static int opt_xsks_num = 1;
static int opt_poll;
static int opt_interval = 1;


static const char *opt_if = "";
static int opt_ifindex;
static int opt_queue;

static u32 opt_xdp_flags = XDP_FLAGS_UPDATE_IF_NOEXIST;

static u32 prog_id;

static unsigned long pre_time;

static const char pkt_data[] =
	"\x3c\xfd\xfe\x9e\x7f\x71\xec\xb1\xd7\x98\x3a\xc0\x08\x00\x45\x00"
	"\x00\x2e\x00\x00\x00\x00\x40\x11\x88\x97\x05\x08\x07\x08\xc8\x14"
	"\x1e\x04\x10\x92\x10\x92\x00\x1a\x6d\xa3\x34\x33\x1f\x69\x40\x6b"
	"\x54\x59\xb6\x14\x2d\x11\x44\xbf\xaf\xd9\xbe\xaa";

//xsk umem info including FILL&COMPLETE ring
struct xsk_umem_info
{	
	struct xsk_ring_prod fq;	//FILL
	struct xsk_ring_cons cq;	//COMPLETE
	struct xsk_umem *umem;
	void *area;
};

//socket info including TX&RX ring
struct xsk_socket_info
{
	struct xsk_ring_prod tx;	//TX
	struct xsk_ring_cons rx;	//RX
	struct xsk_umem_info *umem;
	struct xsk_socket *xsk;
	unsigned long tx_npkts;
	unsigned long rx_npkts;
	unsigned long pre_tx_npkts;
	unsigned long pre_rx_npkts;
	u64 outstanding_tx;
};

//sockets
static int xsk_index = 0;
struct xsk_socket_info *xsks[MAX_SOCKS];

//load xdp program
static void load_xdp_program(char **argv, struct bpf_object **obj)
{
	printf("----load xdp program----\n");
	struct bpf_prog_load_attr prog_load_attr = {
		.prog_type      = BPF_PROG_TYPE_XDP,
	};
	char xdp_filename[256];
	int prog_fd;

	snprintf(xdp_filename, sizeof(xdp_filename), "%s_kern.o", argv[0]);
	prog_load_attr.file = xdp_filename;

	if (bpf_prog_load_xattr(&prog_load_attr, obj, &prog_fd))
		exit(EXIT_FAILURE);
	printf("prog_fd = %d\n", prog_fd);
	if (prog_fd < 0) {
		fprintf(stderr, "ERROR: no program found: %s\n",
			strerror(prog_fd));
		exit(EXIT_FAILURE);
	}

	if (bpf_set_link_xdp_fd(opt_ifindex, prog_fd, opt_xdp_flags) < 0) {
		fprintf(stderr, "ERROR: link set xdp fd failed\n");
		exit(EXIT_FAILURE);
	}
}

//print bench mark
static void print_benchmark(bool running)
{
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

//get current time(secs)
static unsigned long get_nsecs(void)
{
	struct timespec ts;

	clock_gettime(CLOCK_MONOTONIC, &ts);
	return ts.tv_sec * 1000000000UL + ts.tv_nsec;
}

//dump(resave) current statistics 
static void dump_stats(){
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


static void remove_xdp_program(void)
{
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

static void __exit_with_error(int error, const char *file, const char *func,
			      int line)
{
	fprintf(stderr, "%s:%s:%i: errno: %d/\"%s\"\n", file, func,
		line, error, strerror(error));
	dump_stats();
	remove_xdp_program();
	exit(EXIT_FAILURE);
}

#define exit_with_error(error) __exit_with_error(error, __FILE__, __func__, \
						 __LINE__)

//normal_exit
static void normal_exit(int sig)
{
	printf("----normal_exit----\n");
	struct xsk_umem *umem = xsks[0]->umem->umem;
	int i;

	dump_stats();
	for (i = 0; i < xsk_index; i++)
		xsk_socket__delete(xsks[i]->xsk);
	xsk_umem__delete(umem);
	remove_xdp_program();

	exit(EXIT_SUCCESS);
}


//xsk configure umem
static struct xsk_umem_info *xsk_configure_umem(){
	printf("----xsk configure umem----%d-%d-%d-%d\n", opt_xsk_frame_size, frame_headroom, opt_umem_flags, opt_mmap_flags);
	//umem config
	struct xsk_umem_config cfg = {
		.fill_size = XSK_RING_PROD__DEFAULT_NUM_DESCS,
		.comp_size = XSK_RING_PROD__DEFAULT_NUM_DESCS,
		.frame_size = opt_xsk_frame_size,
		.frame_headroom = frame_headroom,
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

static void xsk_populate_fill_ring(struct xsk_umem_info *umem)
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

//config & create socket
static struct xsk_socket_info *xsk_configure_socket(struct xsk_umem_info *umem, bool rx, bool tx){
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
	printf("----opt_if=%s\n", opt_if);
	int ret = xsk_socket__create(&xsk->xsk, opt_if, opt_queue, umem->umem, rxr, txr, &cfg);
	printf("ret = %d\n", ret);
	if(ret)
		exit_with_error(-ret);

	//get xdp id
	int xdpid = bpf_get_link_xdp_id(opt_ifindex, &prog_id, opt_xdp_flags);	
	if(xdpid)
		exit_with_error(-xdpid);

	return xsk; 
}


static struct option long_options[] = {
	{"rxdrop", no_argument, 0, 'r'},
	{"txonly", no_argument, 0, 't'},
	{"l2fwd", no_argument, 0, 'l'},
	{"interface", required_argument, 0, 'i'},
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

static void usage(const char *prog)
{
	const char *str =
		"  Usage: %s [OPTIONS]\n"
		"  Options:\n"
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

//parse command line input
static void parse_command_line(int argc, char **argv)
{
	int option_index, c;

	for (;;) {
		c = getopt_long(argc, argv, "Frtli:q:psSNn:czf:muM",
				long_options, &option_index);
		if (c == -1)
			break;

		switch (c) {
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

	opt_ifindex = if_nametoindex(opt_if);
	if (!opt_ifindex) {
		fprintf(stderr, "ERROR: interface \"%s\" does not exist\n",
			opt_if);
		usage(basename(argv[0]));
	}

	if ((opt_xsk_frame_size & (opt_xsk_frame_size - 1)) &&
	    !opt_unaligned_chunks) {
		fprintf(stderr, "--frame-size=%d is not a power of two\n",
			opt_xsk_frame_size);
		usage(basename(argv[0]));
	}
}

//
static void configure_bpf_map(struct bpf_object *bpf_obj){
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

static void gen_eth_frame(struct xsk_umem_info *umem, u64 addr)
{
	memcpy(xsk_umem__get_data(umem->umem_area, addr), pkt_data,
	       sizeof(pkt_data) - 1);
	//return sizeof(pkt_data) - 1;
}

int main(int argc, char **argv)
{
	struct rlimit r = {RLIM_INFINITY, RLIM_INFINITY};

	bool rx = false, tx = false;
	struct bpf_object *bpf_obj;

	//command line option for changing config
	parse_command_line(argc, argv);

	if (setrlimit(RLIMIT_MEMLOCK, &r)) {
		fprintf(stderr, "ERROR: setrlimit(RLIMIT_MEMLOCK) \"%s\"\n",
			strerror(errno));
		exit(EXIT_FAILURE);
	}

	if(opt_xsks_num > 1)
		load_xdp_program(argv, &bpf_obj);

	//config & create umem
	struct xsk_umem_info *umem = xsk_configure_umem();

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

	signal(SIGINT, normal_exit);
	signal(SIGTERM, normal_exit);
	signal(SIGABRT, normal_exit);

	setlocale(LC_ALL, "");

}

