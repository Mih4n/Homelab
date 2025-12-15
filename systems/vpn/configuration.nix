{ inputs, config, ... }: {
    imports = [
        inputs.disko.nixosModules.default
        inputs.sops-nix.nixosModules.sops
        inputs.vscode-server.nixosModules.default

        ./modules

        ../.modules
        ../.modules/kernel/disko/standard.nix

        ./hardware-configuration.nix
    ];

    bytes = let 
        secrets = config.sops.secrets;
    in {
        hostName = "vpn";

        disk.type = "vda";
        boot.mode = "legacy-grub";

        vscode.enable = true;

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