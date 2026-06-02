{ ... }: {
    flake.nixosModules.hostBytesDhcp = { ... }: {
        services.dnsmasq = {
            enable = true;
            settings = {
                port = 0;
                interface = "vmbrlo";
                bind-interfaces = true;
                
                dhcp-range = "192.168.192.50,192.168.192.100,255.255.255.0,12h";
            
                dhcp-option = [
                    "3,192.168.192.5"
                    "6,8.8.8.8,1.1.1.1" 
                ];

                dhcp-host = [
                    "bc:24:11:a7:fb:50,192.168.192.10" 
                ];
            };
        };

        systemd.services.dnsmasq = {
            after = [ "network.target" "systemd-networkd.service" ];
            requires = [ "network.target" ];
            preStart = ''
                # Wait for vmbrlo interface to appear
                for i in $(seq 1 30); do
                    if ip link show vmbrlo >/dev/null 2>&1; then
                        exit 0
                    fi
                    sleep 1
                done
                echo "vmbrlo interface not found"
                exit 1
            '';
        };
    };
}