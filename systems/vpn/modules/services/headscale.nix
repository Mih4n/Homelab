{
    services.headscale = {
        enable = true;
        port = 3009;
        settings = {
            server_url = "https://vpn.mih4n.xyz";
            dns = {
                base_domain = "bytes";
            };
        };
    };
}