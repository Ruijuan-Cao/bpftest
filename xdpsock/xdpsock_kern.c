#include <linux/bpf.h>
#include <bpf/bpf_helpers.h>

#define MAX_SOCKS 16

//map to handle xsk, key is IP protocol, value is pkt count
struct bpf_map_def SEC("maps") xsks_map = {
        .type = BPF_MAP_TYPE_XSKMAP,
        .key_size = sizeof(int),
        .value_size = sizeof(int),
        .max_entries = MAX_SOCKS,
};

//static value(the counter)
static unsigned int rid; //recv socket id

//xdp socket program
SEC("xdp_sock") int xdp_sock_prog(struct xdp_md *ctx){
        rid = (rid + 1) & (MAX_SOCKS - 1);      //++,%MAX_SOCKS
        //Redirect the packet to the endpoint referenced by map at rid key.
        //XDP_DROP flags are used as the return code if the map lookup fails
        return bpf_redirect_map(&xsks_map, rid, XDP_DROP);
}