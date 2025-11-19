{
    services.dnsmasq = {
        enable = true;
        settings = {
            interface = "vmbrlo";
            port = 0;
            
            dhcp-range = "192.168.192.50,192.168.192.100,255.255.192.0,12h";
        
            dhcp-option = [
                "3,192.168.192.5"
                "6,8.8.8.8,1.1.1.1" 
            ];

            dhcp-host = [
                "bc:24:11:a7:fb:50,192.168.192.10" 
            ];
        };
    };
}