{
    networking.useNetworkd = true;

    networking.hostName = "bytes";
    
    networking.firewall.enable = false;
    networking.networkmanager.enable = false;
    networking.interfaces.enp4s0.useDHCP = false;

    boot.kernelModules = [ "dummy" ];

    networking.bridges = {
        vmbr0.interfaces = [ "enp4s0" ];
        vmbrlo.interfaces = [ "dummy0" ];
    };

    systemd.network.netdevs."10-dummy0" = {
        netdevConfig = {
            Kind = "dummy";
            Name = "dummy0";
        };
    };

    networking.interfaces = {
        vmbr0 = {
            ipv4.addresses = [
                {
                    address = "192.168.0.2";
                    prefixLength = 24;
                }
            ];
            useDHCP = false;
        };

        vmbrlo = {
            useDHCP = false;
            ipv4.addresses = [
                {
                    address = "192.168.192.5";
                    prefixLength = 18;
                }
            ];
        };
    };

    networking.nftables = {
        enable = true;
        ruleset = ''
            table ip nat {
                chain postrouting {
                    type nat hook postrouting priority 100; policy accept;
                    ip saddr 192.168.192.0/18 oifname "vmbr0" masquerade
                }
            }
        '';
    };

    networking.defaultGateway = {
        address = "192.168.0.1";
        interface = "vmbr0";
    };
    
    networking.nameservers = [ "192.168.0.1" "8.8.8.8" "1.1.1.1" ];
}