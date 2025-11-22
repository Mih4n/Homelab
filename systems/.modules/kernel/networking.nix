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
    };

    config = {
        networking = lib.mkIf config.bytes.local-networking.enable {
            useDHCP = lib.mkDefault false;

            interfaces.ens18 = {
                useDHCP = false;
                ipv4.addresses = [
                    {
                        address = config.bytes.local-networking.ip;
                        prefixLength = 18;      
                    }
                ];

            };

            defaultGateway = "192.168.192.5";
        };
    };
}