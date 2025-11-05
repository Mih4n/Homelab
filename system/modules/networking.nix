{
    networking.hostName = "bytes";
    networking.firewall.enable = false;
    networking.interfaces.enp4s0.useDHCP = false;

    networking.bridges = {
        vmbr0.interfaces = [ "enp4s0" ];
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
    };

    networking.defaultGateway = {
        address = "192.168.0.1";
        interface = "vmbr0";
    };
    
    networking.nameservers = [ "192.168.0.1" "8.8.8.8" "1.1.1.1" ];
}