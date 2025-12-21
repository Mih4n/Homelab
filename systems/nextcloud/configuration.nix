{ inputs, config, ... }: {
    imports = [ 
        inputs.disko.nixosModules.default

        ./modules

        ../.modules
        ../.modules/kernel/disko/standard.nix

        ./hardware-configuration.nix
    ];

    bytes = let 
        secrets = config.sops.secrets;
    in {
        hostName = "nextcloud";
        
        local-networking = {
            enable = true;
            ip = "192.168.192.11";
        };

        tailscale = {
            enable = true;
            authKeyFile = secrets."headscale/nextcloud".path;
        };
    };
 
    system.stateVersion = "25.05";
}