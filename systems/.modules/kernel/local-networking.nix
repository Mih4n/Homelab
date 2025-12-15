{ lib, config, ... }: {
    options.bytes.local-networking = { 
        enable = lib.mkEnableOption "local networking";

        ip = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "ip address in local network";
        };

        mask = lib.mkOption {
            type = lib.types.int;
            default = 24;
            description = "sets local network mask";
        };

        useDHCP = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "enables dhcp";
        };
    };

    config = let 
        cfg = config.bytes.local-networking;
    in {
        networking = lib.mkIf cfg.enable {
            useDHCP = cfg.useDHCP;

            firewall.enable = false;

            interfaces.ens18 = {
                useDHCP = cfg.useDHCP;
                ipv4.addresses = lib.mkIf (!cfg.useDHCP) [
                    {
                        address = cfg.ip;
                        prefixLength = cfg.mask;      
                    }
                ];

            };

            nameservers = [ "192.168.192.5" ];

            defaultGateway = "192.168.192.5";
        };
    };
}