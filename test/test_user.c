
int main(int argc, char **argv)
{
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

	/* Required option */
	if (cfg.ifindex == -1) {
		fprintf(stderr, "ERR: required option --dev missing\n");
		usage(argv[0], __doc__, long_options, (argc == 1));
		return EXIT_FAIL_OPTION;
	}
	if (cfg.do_unload)
		return xdp_link_detach(cfg.ifindex, cfg.xdp_flags, 0);


	//bpf object
	struct bpf_object *bpf_obj = load_bpf_and_xdp_attach(&cfg);
	if (!bpf_obj)
		return EXIT_FAIL_BPF;

	

}