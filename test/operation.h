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

static bool opt_need_wakeup = true;

static int opt_xsks_num = 1;
static int opt_poll;
static int opt_interval = 1;

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
void gen_eth_frame(struct xsk_umem_info *umem, u64 addr);

//input & output
void usage(const char *prog);
void print_benchmark(bool running);
void dump_stats();	//dump current statistics 
void parse_command_line(int argc, char **argv);

//exit
void __exit_with_error(int error, const char *file, const char *func, int line);
#define exit_with_error(error) __exit_with_error(error, __FILE__, __func__, __LINE__)
void normal_exit(int sig);

//xdp program
void load_xdp_program(char **argv, struct bpf_object **obj);
void remove_xdp_program();

//xsk configure umem
static struct xsk_umem_info *xsk_configure_umem();
void xsk_populate_fill_ring(struct xsk_umem_info *umem);
static u64 xsk_alloc_umem_frame(struct xsk_socket_info *xsk);
void xsk_free_umem_frame(struct xsk_socket_info *xsk, u64 frame);

//config & create socket
static struct xsk_socket_info *xsk_configure_socket(struct xsk_umem_info *umem, bool rx, bool tx);

//configure bpf map
void configure_bpf_map(struct bpf_object *bpf_obj);

//kick_tx, keep wake
void kick_tx(struct xsk_socket_info *xsk);

#endif //OPERATION_H