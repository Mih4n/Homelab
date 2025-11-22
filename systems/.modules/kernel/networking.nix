{ lib, config, ... }: {
    options.bytes.local-networking = { 
        enable = lib.mkOption {
            type = lib.types.bool;
            default = false; 
            description = "enables local networking";
        };

        ip = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "ip address in local network";
        };

        hostName = lib.mkOption {
            type = lib.types.str;
            default = "nixos";
            description = "sets host name for the host";
        };
    };

    config = {
        networking = lib.mkIf config.bytes.local-networking.enable {
            hostName = config.bytes.local-networking.hostName;

            useDHCP = lib.mkDefault false;

            firewall.enable = false;

            interfaces.ens18 = {
                useDHCP = false;
                ipv4.addresses = [
                    {
                        address = config.bytes.local-networking.ip;
                        prefixLength = 18;      
                    }
                ];

            };

            nameservers = [ "192.168.192.5" "1.1.1.1" "8.8.8.8" ];

            defaultGateway = "192.168.192.5";
        };
    };
}