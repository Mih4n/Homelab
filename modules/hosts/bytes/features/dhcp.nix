{ self, ... }: let
    s = self.settings;
in {
    flake.nixosModules.hostBytesDhcp = { ... }: {
        services.dnsmasq = {
            enable = true;
            settings = {
                port = 0;
                interface = "vmbrlo";
                bind-interfaces = true;
                
                dhcp-range = "192.168.192.50,192.168.192.100,255.255.255.0,12h";
            
                dhcp-option = [
                    "3,${s.net.gateway}"
                    "6,8.8.8.8,1.1.1.1" 
                ];

                dhcp-host = [
                    "bc:24:11:a7:fb:50,${s.net.ips.homeassistant}" 
                ];
            };
        };

        systemd.services.dnsmasq = {
            requires = [ "network.target" "systemd-networkd.service" ];
            after = [ "network.target" "systemd-networkd.service" "vmbrlo-nic.service" ];
            wants = [ "vmbrlo-nic.service" ];
        };
    };
}