{ lib, config, ... }: {
    options.bytes.local-networking = { 
        enable = lib.mkEnableOption "local networking";

        ip = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "ip address in local network";
        };

        useDHCP = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = "enables dhcp";
        };
    };

    config = let 
        local-network = config.bytes.local-networking;
    in {
        networking = lib.mkIf local-network.enable {
            useDHCP = local-network.useDHCP;

            firewall.enable = false;

            interfaces.ens18 = {
                useDHCP = local-network.useDHCP;
                ipv4.addresses = lib.mkIf (!local-network.useDHCP) [
                    {
                        address = config.bytes.local-networking.ip;
                        prefixLength = 18;      
                    }
                ];

            };

            nameservers = [ "192.168.192.5" ];

            defaultGateway = "192.168.192.5";
        };
    };
}