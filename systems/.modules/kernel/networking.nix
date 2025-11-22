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

        useDHCP = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "enables dhcp";
        };
    };

    config = let 
        networking = config.bytes.local-networking;
    in {
        networking = lib.mkIf networking.enable {
            hostName = networking.hostName;

            useDHCP = networking.useDHCP;

            firewall.enable = false;

            interfaces.ens18 = {
                useDHCP = networking.useDHCP;
                ipv4.addresses = lib.mkIf (!networking.useDHCP) [
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