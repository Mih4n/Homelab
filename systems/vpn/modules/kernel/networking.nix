{
    networking = {
        useDHCP = false;

        interfaces.ens18 = {
            macAddress = "00:50:56:00:B7:51"; 
            
            ipv4.addresses = [
                {
                    address = "157.180.52.198";
                    prefixLength = 26;
                }
            ];
        };

        defaultGateway = "157.180.52.193";
    };
}