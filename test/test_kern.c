/* test_kernel, for AF-XDP learning */
#include <linux/bpf.h>
#include <linux/if_ether.h>
#include <linux/if_vlan.h>
#include <linux/ipv6.h>

#include <bpf/bpf_helpers.h>
#include <bpf/bpf_endian.h>

//define the max action mode of bpf map
#ifndef XDP_ACTION_MAX
#define XDP_ACTION_MAX XDP_REDIRECT + 1
#endif

/* Allow users of header file to redefine VLAN max depth */
#ifndef VLAN_MAX_DEPTH
#define VLAN_MAX_DEPTH 4
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
		return XDP_ABORTED;

	lock_xadd(&pkt->rx_packets, 1);	

	return XDP_PASS;
}

//header cursor to track current parsing position
struct hdr_cursor{
	void *pos;
};

/*
 *	struct vlan_hdr - vlan header
 *	@h_vlan_TCI: priority and VLAN ID
 *	@h_vlan_encapsulated_proto: packet type ID or len
 */

struct vlan_hdr {
	__be16	h_vlan_TCI;
	__be16	h_vlan_encapsulated_proto;
};

static __always_inline int proto_is_vlan(__u16 h_proto)
{
	return !!(h_proto == bpf_htons(ETH_P_8021Q) ||
		  h_proto == bpf_htons(ETH_P_8021AD));
}

//parse ethhdr
static __always_inline int parse_ethhdr(struct hdr_cursor *hc, void *data_end, struct ethhdr **ethhdr)
{
	struct ethhdr *eth = hc->pos;
	int hdr_size = sizeof(*eth);

	if (hc->pos + 1 > data_end)
		return -1;
	
	//update the header cursor
	hc->pos += hdr_size;
	*ethhdr = eth;

	__u16 h_proto;
	h_proto = eth->h_proto;

	struct vlan_hdr *vlh;
	vlh = hc->pos;

	// Use loop unrolling to avoid the verifier restriction on loops;
	// support up to VLAN_MAX_DEPTH layers of VLAN encapsulation.
	#pragma unroll
	for (int i = 0; i < VLAN_MAX_DEPTH; i++) {
		if (!proto_is_vlan(h_proto))
			break;

		if (vlh + 1 > data_end)
			break;

		h_proto = vlh->h_vlan_encapsulated_proto;
		vlh++;
	}

	hc->pos = vlh;
	return h_proto;
}


//filter ipv6
SEC("xdp_ipv6_pass")
int xdp_parser_func(struct xdp_md *ctx)
{
	void *data = (void *)(long)ctx->data;
	void *data_end = (void *)(long)ctx->data_end;

	//start new header cursor postion at data start
	struct hdr_cursor hc = {.pos = data};

	//parse proto
	struct ethhdr *eth;
	int proto = parse_ethhdr(&hc, data_end, &eth);
	if(bpf_htons(proto) != ETH_P_IPV6)
		return XDP_DROP;
	
	return XDP_PASS;
	//read via xdp_stats
	//return xdp_stats_record_action(ctx, action); 
}


char _license[] SEC("license") = "GPL";