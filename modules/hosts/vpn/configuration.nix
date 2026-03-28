{ inputs, config, ... }: {
    imports = [
        inputs.disko.nixosModules.default

        ./modules

        ../.modules
        ../.modules/kernel/disko/standard.nix

        ./hardware-configuration.nix
    ];

    networking.hostName = "vpn";

    bytes = let 
        secrets = config.sops.secrets;
    in {
        boot.enable = true;

        disk.type = "sda";
        boot.mode = "legacy-grub";

        headscale = {
            subnetRouters = [
                "bytes"
            ];
        };
        
        tailscale = {
            enable = true;
            isExiteNode = true;
            authKeyFile = secrets."headscale/vpn".path;
        };
    }; 
 
    system.stateVersion = "25.05";
}