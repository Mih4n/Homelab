{
    services.headscale = {
        enable = true;
        port = 3009;
        settings = {
            server_url = "https://vpn.mih4n.xyz";
            dns = {
                base_domain = "bytes";
                nameservers.global = [ "8.8.8.8" "1.1.1.1" ];
            };
        };
    };
}