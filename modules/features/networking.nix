{ ... }: {
    flake.nixosModules.networking = { ... }: {
        networking = {
            firewall = {
                allowedTCPPorts = [ 22 80 8080 443 25 465 993 587 443 ];
            };

            nameservers = [ "176.99.11.77" "80.78.247.254" ];
        };
    };
}
