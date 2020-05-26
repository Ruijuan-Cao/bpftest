/* test_kernel, for AF-XDP learning */
#include <linux/bpf.h>
#include <linux/if_ether.h>
#include <linux/if_vlan.h>
#include <linux/in.h>
#include <linux/ip.h>
#include <linux/ipv6.h>
#include <linux/udp.h>

#include <bpf/bpf_helpers.h>
#include <bpf/bpf_endian.h>

#include "common_defs.h"

//define the max action mode of bpf map
#ifndef XDP_ACTION_MAX
#define XDP_ACTION_MAX XDP_REDIRECT + 1
#endif

/* Allow users of header file to redefine VLAN max depth */
#ifndef VLAN_MAX_DEPTH
#define VLAN_MAX_DEPTH 4
#endif

#define SEC(NAME) __attribute__((section(NAME), used))

#define htons(x) ((__be16)___constant_swab16((x)))
#define htonl(x) ((__be32)___constant_swab32((x)))

//map for count the passed packet
struct bpf_map_def SEC("maps") bpf_pass_map =
{
	.type		= BPF_MAP_TYPE_ARRAY,
	.key_size	= sizeof(__u32),
	.value_size	= sizeof(__u64),
	.max_entries= XDP_ACTION_MAX,
};

//status map
struct bpf_map_def SEC("maps") xdp_stats_map =
{	
	.type 		= BPF_MAP_TYPE_ARRAY,
	.key_size	= sizeof(__u32),
	.value_size = sizeof(struct datarec),
	.max_entries = XDP_ACTION_MAX,
};

//fetch and add value to ptr
#ifndef lock_xadd
#define lock_xadd(ptr, val) ((void) __sync_fetch_and_add(ptr, val))
#endif

/*
 *	struct vlan_hdr - vlan header
 *	@h_vlan_TCI: priority and VLAN ID
 *	@h_vlan_encapsulated_proto: packet type ID or len
 */

struct vlan_hdr {
	__be16	h_vlan_TCI;
	__be16	h_vlan_encapsulated_proto;
};

SEC("xdp_pass")
int xdp_pass_func(struct xdp_md *ctx)
{	
	struct datarec *rec;
	__u32 key = XDP_PASS;
	rec = bpf_map_lookup_elem(&bpf_pass_map, &key);
	if (!rec)
		return XDP_ABORTED;

	//get data header
	void *data_end = (void *)(long)ctx->data_end;
	void *data = (void *)(long)ctx->data;
	struct ethhdr *eth = data;

	//check size
	__u64 addr_off = sizeof(*eth);
	if (data + addr_off > data_end){
		lock_xadd(&rec->rx_packets, 1);
		return XDP_PASS;
	}

	__u64 h_proto = eth->h_proto;

	//vlan - handle doubel VLAN tagged packet
	for(int i = 0; i < 2; i++){
		if (h_proto == htons(ETH_P_8021Q) || h_proto == htons(ETH_P_8021AD)){
			struct vlan_hdr *vhdr = data + addr_off;
			addr_off += sizeof(struct vlan_hdr);
			if (data + addr_off > data_end){
				lock_xadd(&rec->rx_packets, 1);
				return XDP_PASS;
			}
			h_proto = vhdr->h_vlan_encapsulated_proto;
		}
	}

	//ipv4
	if (h_proto == htons(ETH_P_IP)){
		struct iphdr *iph = data + addr_off;
		struct udphdr *udph = data + addr_off + sizeof(struct iphdr);
		if (udph + 1 > (struct udphdr *)data_end){
			lock_xadd(&rec->rx_packets, 1);
			return XDP_PASS;
		}
		//UDP
		if (iph->protocol == IPPROTO_UDP 
			//source address
			&& (htonl(iph->saddr) & 0xFFFFFF00) == 0xC0A8E300
			&& udph->dest == htons(12345) ){
				rec->saddr = htonl(iph->saddr);
				return XDP_DROP;
		}
	}
	else if (h_proto == htons(ETH_P_IPV6)){
		struct ipv6hdr * ipv6h = data + addr_off;
		struct udphdr * udph = data + addr_off + sizeof(struct ipv6hdr);
		if (udph + 1 > (struct udphdr *)data_end)
			return XDP_PASS;
		if (ipv6h->nexthdr == IPPROTO_UDP 
			&& ipv6h->daddr.s6_addr[0] == 0xfd
			&& ipv6h->daddr.s6_addr[1] == 0x00
			&& udph->dest == htons(12345)){
			//rec->daddr = htonl(ipv6h->daddr);
			return XDP_DROP;	
		}
	}

	lock_xadd(&rec->rx_packets, 1);	

	return XDP_PASS;
}

SEC("filter")
int xdp_filter_func(struct xdp_md *ctx)
{
	//get map pointer
	__u32 key = XDP_PASS;
	struct datarec *rec = bpf_map_lookup_elem(&xdp_stats_map, &key);
	if (!rec)
		return XDP_ABORTED;

	//get data header
	void *data_end = (void *)(long)ctx->data_end;
	void *data = (void *)(long)ctx->data;
	struct ethhdr *eth = data;

	//check size
	__u64 addr_off = sizeof(*eth);
	if (data + addr_off > data_end){
		lock_xadd(&rec->rx_packets, 1);
		return XDP_PASS;
	}

	__u64 h_proto = eth->h_proto;

	//vlan - handle doubel VLAN tagged packet
	for(int i = 0; i < 2; i++){
		if (h_proto == htons(ETH_P_8021Q) || h_proto == htons(ETH_P_8021AD)){
			struct vlan_hdr *vhdr = data + addr_off;
			addr_off += sizeof(struct vlan_hdr);
			if (data + addr_off > data_end){
				lock_xadd(&rec->rx_packets, 1);
				return XDP_PASS;
			}
			h_proto = vhdr->h_vlan_encapsulated_proto;
		}
	}

	//ipv4
	if (h_proto == htons(ETH_P_IP)){
		struct iphdr *iph = data + addr_off;
		struct udphdr *udph = data + addr_off + sizeof(struct iphdr);
		if (udph + 1 > (struct udphdr *)data_end){
			lock_xadd(&rec->rx_packets, 1);
			return XDP_PASS;
		}
		//UDP
		if (iph->protocol == IPPROTO_UDP 
			//source address
			&& (htonl(iph->saddr) & 0xFFFFFF00) == 0xC0A8E300
			&& udph->dest == htons(12345) ){
				rec->saddr = htonl(iph->saddr);
				return XDP_DROP;
		}
	}
	else if (h_proto == htons(ETH_P_IPV6)){
		struct ipv6hdr * ipv6h = data + addr_off;
		struct udphdr * udph = data + addr_off + sizeof(struct ipv6hdr);
		if (udph + 1 > (struct udphdr *)data_end)
			return XDP_PASS;
		if (ipv6h->nexthdr == IPPROTO_UDP 
			&& ipv6h->daddr.s6_addr[0] == 0xfd
			&& ipv6h->daddr.s6_addr[1] == 0x00
			&& udph->dest == htons(12345)){
			//rec->daddr = htonl(ipv6h->daddr);
			return XDP_DROP;	
		}
	}

	lock_xadd(&rec->rx_packets, 1);
    return XDP_PASS;
}

SEC("xxx")
int just_test(struct xdp_md *ctx){
	return XDP_PASS;
}

char _license[] SEC("license") = "GPL";
