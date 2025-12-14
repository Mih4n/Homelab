{ config, lib, ... }: {
    options.bytes.tailscale.enable = lib.mkEnableOption "tailscale";

    config = lib.mkIf config.bytes.tailscale.enable {
        services.tailscale = {
            enable = true;
        };

        networking.firewall = {
            trustedInterfaces = [ config.services.tailscale.interfaceName ];
            allowedUDPPorts = [ config.services.tailscale.port ];
            checkReversePath = "loose";
        };
    };
}