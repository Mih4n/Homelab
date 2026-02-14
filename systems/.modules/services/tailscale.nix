{ config, lib, pkgs, ... }: {
    options.bytes.tailscale = {
        enable = lib.mkEnableOption "tailscale";
        isExiteNode = lib.mkEnableOption "exit node";
        subnetRoutes = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
        };
        loginServer = lib.mkOption {
            type = lib.types.str;
            default = "https://vpn.mih4n.xyz";
        };
        authKeyFile = lib.mkOption {
            type = lib.types.nullOr lib.types.path;
            default = null;
        };
    };

    config = let
        cfg = config.bytes.tailscale; 
    in lib.mkIf cfg.enable {
        services.tailscale = {
            enable = true;
            openFirewall = true;
            authKeyFile = cfg.authKeyFile;
            useRoutingFeatures = "both";
            extraUpFlags = [ 
                "--login-server=${cfg.loginServer}"
                "--accept-routes"
            ] ++ lib.optionals cfg.isExiteNode [
                "--advertise-exit-node"
            ] ++ lib.optionals (lib.any (x: true) cfg.subnetRoutes) [
                "--advertise-routes=${lib.concatStringsSep "," cfg.subnetRoutes}"
            ];
        };

        boot.kernelModules = [ "udp_tunnel" "ip6_udp_tunnel" ];
        boot.kernel.sysctl = {
            "net.core.default_qdisc" = "fq";
            "net.ipv4.tcp_congestion_control" = "bbr";
            
            "net.core.rmem_max" = 8388608;
            "net.core.wmem_max" = 8388608;
        };

        services.networkd-dispatcher = lib.mkIf config.services.tailscale.enable {
            enable = true;
            rules."50-tailscale" = {
                onState = ["routable"];
                script = ''
                    # Find the interface used for the default route, excluding tailscale
                    NETDEV=$(ip route show 0.0.0.0/0 dev tailscale0 table main 2>/dev/null | grep -v tailscale || ip route show 0.0.0.0/0 | cut -d ' ' -f 5)
                    
                    # Safety check to ensure we found a device and it's not tailscale
                    if [[ -n "$NETDEV" && "$NETDEV" != "tailscale0" ]]; then
                        ${pkgs.ethtool}/bin/ethtool -K "$NETDEV" rx-udp-gro-forwarding on rx-gro-list off
                    fi
                '';
            };
        };

        networking.firewall = {
            trustedInterfaces = [ config.services.tailscale.interfaceName ];
            allowedUDPPorts = [ config.services.tailscale.port ];
            checkReversePath = "loose";
        };
    };
}