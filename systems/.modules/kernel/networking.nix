{ config, lib, ... }: {
    options.bytes = {
        hostName = lib.mkOption {
            type = lib.types.str;
            default = "nixos";
            description = "host name";
        };
    };

    config = {
        networking = {
            hostName = config.bytes.hostName;

            firewall = {
                allowedTCPPorts = [ 22 80 443 ];
            };

            nameservers = [ "1.1.1.1" "8.8.8.8" ];
        };
    };
}