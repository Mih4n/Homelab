{ ... }: {
    flake.nixosModules.localNetworking = { lib, config, ... }: let 
        cfg = config.bytes.networking.local;
    in {
        networking = {
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