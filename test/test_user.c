#include <errno.h>
#include <linux/bpf.h>
#include <linux/if_xdp.h>
#include <sys/mman.h>
#include <sys/resource.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <stdio.h>
#include <stdlib.h>

#include <bpf/libbpf.h>
#include <bpf/xsk.h>
#include <bpf/bpf.h>

#include "common_defs.h"

#ifndef MAX_SOCKS
#define MAX_SOCKS 4
#endif

typedef __u64 u64;
typedef __u32 u32;

#define FRAME_NUM (4 * 1024)
#define BATCH_SIZE	64
static int frame_size = XSK_UMEM__DEFAULT_FRAME_SIZE;
static int frame_headroom = XSK_UMEM__DEFAULT_FRAME_HEADROOM;
static int opt_umem_flags = XSK_UMEM__DEFAULT_FLAGS;
static int opt_mmap_flags = 0;
static int opt_xsks_num = 1;

static const char *opt_if = "";
static int opt_ifindex;
static int opt_queue;

static u32 opt_xdp_flags = XDP_FLAGS_UPDATE_IF_NOEXIST;

static u32 prog_id;

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
	struct xsl_socket *xsks;
	unsigned long tx_npkts;
	unsigned long rx_npkts;
	unsigned long pre_tx_npkts;
	unsigned long pre_rx_npkts;
	u64 outstanding_tx;
};

//sockets
static int xsk_index = 0;
struct xsk_socket_info **xsks[MAX_SOCKS];

//xsk configure umem
static struct xsk_umem_info *xsk_configure_umem(){
	//umem config
	struct xsk_umem_config cfg = {
		.fill_size = XSK_RING_PROD__DEFAULT_NUM_DESCS,
		.comp_size = XSK_RING_PROD__DEFAULT_NUM_DESCS,
		.frame_size = frame_size,
		.frame_headroom = frame_headroom,
		.flags = opt_umem_flags,
	};
	//umem calloc
	struct xsk_umem_info *umem = calloc(1, sizeof(*umem));
	if (!umem)
		exit_with_error(errno);

	//umem area, mmap/munmap - map or unmap files or devices into memory
	void *umem_area = mmap(NULL, FRAME_NUM * frame_size,
		    PROT_READ | PROT_WRITE,
		    MAP_PRIVATE | MAP_ANONYMOUS | opt_mmap_flags, -1, 0);
	if (umem_area == MAP_FAILED)
	{
		printf("mmap failed\n");
		exit_with_error(errno);		
	}

	//create umem
	int ret = xsk_umem__create(&umem->umem, umem_area, FRAME_NUM * frame_size, &umem->fq, &umem->cq, &cfg);
	if (ret)
	 	exit_with_error(ret);

	 umem->area = umem_area;
	 return umem;
}

static void xsk_populate_fill_ring(struct xsk_umem_info *umem)
{
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
	//config
	struct xsk_socket_config cfg;
	struct xsk_socket info *xsk;
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

	return xsk; 
}

//load xdp program
static void load_xdp_program(char **argv, struct bpf_object **obj)
{
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

int main(int argc, char **argv)
{
	struct rlimit r = {RLIM_INFINITY, RLIM_INFINITY};

	bool rx = false, tx = false;
	struct bpf_object *bpf_obj;

	//define config
	struct config cfg
	{
		.ifindex = -1,
		.do_unload = false,
		.filename = "",
		.progsec = "test"
	};

	//command line option for changing config
	parse_cmdline_args(argc, argv, long_options, &cfg, __doc__);

	if (setrlimit(RLIMIT_MEMLOCK, &r)) {
		fprintf(stderr, "ERROR: setrlimit(RLIMIT_MEMLOCK) \"%s\"\n",
			strerror(errno));
		exit(EXIT_FAILURE);
	}

	if(opt_xsks_num > 1)
		load_xdp_program(argv, &bpf_obj);

	//bpf map
	struct bpf_map *map = bpf_object__find_map_by_name(bpf_obj, "bpf_pass_map");
	int pass_map = bpf_map__fd(map);
	if (pass_map < 0)
	{
		fprintf(stderr, "%s\n", strerror(pass_map));
		exit(EXIT_FAILURE);
	}

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

}