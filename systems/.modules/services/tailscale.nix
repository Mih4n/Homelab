{ config, lib, ... }: {
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

        networking.firewall = {
            trustedInterfaces = [ config.services.tailscale.interfaceName ];
            allowedUDPPorts = [ config.services.tailscale.port ];
            checkReversePath = "loose";
        };
    };
}