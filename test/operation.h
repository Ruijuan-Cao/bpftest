/*
	basic operation of umem and socket
*/
#ifndef OPERATION_H
#define OPERATION_H

#include <stdlib.h>
#include <errno.h>
#include <linux/if_link.h>

#include <bpf/libbpf.h>
#include <bpf/xsk.h>
#include <bpf/bpf.h>

#include "common.h"

static enum benchmark_type opt_bench = BENCH_RXDROP;
static int opt_xsk_frame_size = XSK_UMEM__DEFAULT_FRAME_SIZE;
static int opt_umem_flags = XSK_UMEM__DEFAULT_FLAGS;
static int opt_mmap_flags = 0;
static int opt_unaligned_chunks;

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
	//for stock frames
	u64 umem_frame_addr[FRAME_NUM];
	u64 umem_frame_free;
};

//sockets
static int xsk_index = 0;
struct xsk_socket_info *xsks[MAX_SOCKS];

//get ethert frame
static void gen_eth_frame(struct xsk_umem_info *umem, u64 addr);

//input & output
static void usage(const char *prog);
static void print_benchmark(bool running);
static void dump_stats();	//dump current statistics 
static void parse_command_line(int argc, char **argv);

//exit
static void __exit_with_error(int error, const char *file, const char *func, int line);
#define exit_with_error(error) __exit_with_error(error, __FILE__, __func__, __LINE__)
static void normal_exit(int sig);

//xdp program
static void load_xdp_program(char **argv, struct bpf_object **obj);
static void remove_xdp_program();

//xsk configure umem
static struct xsk_umem_info *xsk_configure_umem();
static void xsk_populate_fill_ring(struct xsk_umem_info *umem);
static u64 xsk_alloc_umem_frame(struct xsk_socket_info *xsk);
static void xsk_free_umem_frame(struct xsk_socket_info *xsk, u64 frame);

//config & create socket
static struct xsk_socket_info *xsk_configure_socket(struct xsk_umem_info *umem, bool rx, bool tx);

//configure bpf map
static void configure_bpf_map(struct bpf_object *bpf_obj);

//kick_tx, keep wake
static void kick_tx(struct xsk_socket_info *xsk);

#endif //OPERATION_H