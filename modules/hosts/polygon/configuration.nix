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
        boot.enable = true;
        hostName = "polygon";
        
        local-networking = {
            enable = true;
            ip = "192.168.192.12";
        };

        tailscale = {
            enable = true;
            authKeyFile = secrets."headscale/polygon".path;
        };
    };
 
    system.stateVersion = "25.05";
}