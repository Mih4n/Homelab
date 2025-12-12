{ config, lib, ... }: {
    options.bytes.tailscale.enable = lib.mkEnableOption "tailscale";

    config = lib.mkIf config.bytes.tailscale.enable {
        services.tailscale = {
            enable = true;
        };
    };
}