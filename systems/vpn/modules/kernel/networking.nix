{
    networking.hostName = "vpn";

    networking.firewall.allowedUDPPorts = [ 3478 ];
    networking.firewall.allowedTCPPorts = [ 80 443 22 ];

    networking = {
        useDHCP = false;

        interfaces.ens3 = {
            macAddress = "52:54:00:f1:e5:bd"; 
            
            ipv4.addresses = [
                {
                    address = "79.137.205.90";
                    prefixLength = 32;
                }
            ];

            ipv6.addresses = [
                {
                    address = "2a01:e5c0:4de6::2";
                    prefixLength = 48;
                }
            ];
            
            ipv4.routes = [
                {
                    address = "10.0.0.1";
                    prefixLength = 32;
                    options = { scope = "link"; };
                }
            ];
        };

        defaultGateway = {
            address = "10.0.0.1";
            interface = "ens3";
        };
        
        nameservers = [ "1.1.1.1" "8.8.8.8" ];
    };
}