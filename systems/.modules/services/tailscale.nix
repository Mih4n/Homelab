{ config, lib, ... }: {
    options.bytes.tailscale = {
        enable = lib.mkEnableOption "tailscale";
        isExiteNode = lib.mkEnableOption "exit node";
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
            ];
        };

        networking.firewall = {
            trustedInterfaces = [ config.services.tailscale.interfaceName ];
            allowedUDPPorts = [ config.services.tailscale.port ];
            checkReversePath = "loose";
        };
    };
}