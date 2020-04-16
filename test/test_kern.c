/* test_kernel, for AF-XDP learning */
#include <linux/bpf.h>
#include <bpf/bpf_helpers.h>

//define the max action mode of bpf map
#ifndef XDP_ACTION_MAX
#define XDP_ACTION_MAX XDP_REDIRECT + 1
#endif

//map for count the passed packet
struct bpf_map_def SEC("maps") bpf_pass_map =
{
	.type		= BPF_MAP_TYPE_ARRAY,
	.key_size	= sizeof(__u32),
	.value_size	= sizeof(__u64),
	.max_entries= XDP_ACTION_MAX,
};

//fetch and add value to ptr
#ifndef lock_xadd
#define lock_xadd(ptr, val) ((void) __sync_fetch_and_add(ptr, val))
#endif

/* This is the data record stored in the map */
struct datarec {
	__u64 rx_packets;
	/* Assignment#1: Add byte counters */
};

SEC("xdp_pass")
int xdp_pass_func(struct xdp_md *ctx)
{	
	struct datarec *pkt;
	__u32 key = XDP_PASS;
	pkt = bpf_map_lookup_elem(&bpf_pass_map, &key);
	if (!pkt)
	{
		return XDP_ABORTED;
	}
	lock_xadd(&pkt->rx_packets, 1);	

	return XDP_PASS;
}

char _license[] SEC("license") = "GPL";