/* SPDX-License-Identifier: GPL-2.0 */

#include <linux/bpf.h>

#include <bpf/bpf_helpers.h>

struct bpf_map_def SEC("maps") xsks_map = {
	.type = BPF_MAP_TYPE_XSKMAP,
	.key_size = sizeof(int),
	.value_size = sizeof(int),
	.max_entries = 64,  /* Assume netdev has no more than 64 queues */
};

struct bpf_map_def SEC("maps") xdp_stats_map = {
	.type        = BPF_MAP_TYPE_PERCPU_ARRAY,
	.key_size    = sizeof(int),
	.value_size  = sizeof(__u32),
	.max_entries = 64,
};

SEC("xdp_sock")
int xdp_sock_prog(struct xdp_md *ctx)
{
    int index = ctx->rx_queue_index;
    __u32 *pkt_count;

    pkt_count = bpf_map_lookup_elem(&xdp_stats_map, &index);
    if (pkt_count) {

        /* We pass every other packet */
        if ((*pkt_count)++ & 1)
            return XDP_PASS;
    }

    /* A set entry here means that the correspnding queue_id
     * has an active AF_XDP socket bound to it. */
    if (bpf_map_lookup_elem(&xsks_map, &index))
        return bpf_redirect_map(&xsks_map, index, 0);

    return XDP_PASS;
}

struct vlan_hdr {
    __be16  h_vlan_TCI;
    __be16  h_vlan_encapsulated_proto;
};

SEC("xdp_filter")
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

char _license[] SEC("license") = "GPL";
