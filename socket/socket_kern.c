#include <linux/bpf.h>
#include <bpf/bpf_helpers.h>

struct {
	__uint(type, BPF_MAP_TYPE_ARRAY);
	__type(key, u32);
	__type(value, long);
	__uint(max_entries, 256);
} my_map SEC(".maps");

/*
 * We are only interested in TCP/UDP headers, so drop every other protocol
 * and trim packets after the TCP/UDP header by returning length of
 * ether header + IPv4 header + TCP/UDP header.
 */
SEC("socket")
int bpf_socket_prog(struct __sk_buff *skb)
{
	//get proto
	int proto = load_byte(skb, ETH_HLEN + offsetof(struct iphdr, protocol));	
	int size = ETH_HLEN + sizeof(struct iphdr);
	
	//check proto
	switch (proto) {
	case IPPROTO_TCP:
		size += sizeof(struct tcphdr);
		break;
	case IPPROTO_UDP:
		size += sizeof(struct udphdr);
		break;
	default:
		size = 0;
		break;
    }

    if (skb->pkt_type != PACKET_OUTGOING)
		return 0;

	value = bpf_map_lookup_elem(&my_map, &proto);
	if (value)
		__sync_fetch_and_add(value, skb->len);

   	return size;
}

char __license[] SEC("license") = "GPL";
