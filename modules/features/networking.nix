{ ... }: {
    flake.nixosModules.networking = { ... }: {
        networking = {
            firewall = {
                allowedTCPPorts = [ 22 80 8080 443 25 465 993 587 443 ];
            };

            nameservers = [ "1.1.1.1" "8.8.8.8" ];
        };
    };
}