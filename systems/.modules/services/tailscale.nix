{ config, lib, ... }: {
    options.bytes.tailscale.enable = lib.mkEnableOption "tailscale";

    config = {
        services.tailscale = {
            enable = config.bytes.tailscale.enable;
        };
    };
}