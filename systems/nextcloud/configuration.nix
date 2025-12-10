{ inputs, ... }: {
    imports = [ 
        inputs.disko.nixosModules.default
        inputs.sops-nix.nixosModules.sops

        ./modules

        ../.modules
        ../.modules/kernel/disko/standard.nix

        ./hardware-configuration.nix
    ];

    bytes = {
        local-networking = {
            enable = true;
            ip = "192.168.192.11";

            hostName = "nextcloud";
        };
    };
 
    system.stateVersion = "25.05";
}