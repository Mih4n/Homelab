{ inputs, config, ... }: {
    imports = [
        inputs.sops-nix.nixosModules.sops
        inputs.authentik.nixosModules.default
        inputs.vscode-server.nixosModules.default
        inputs.proxmox-nixos.nixosModules.proxmox-ve
        
        ./modules
        ../.modules
        
        ./hardware-configuration.nix
    ];

    bytes = let 
        secrets = config.secrets.sops;
    in {
        hostName = "bytes";

        vscode.enable = true;
        tailscale = {
            enable = true;
            isExiteNode = true;
            authKeyFile = secrets."headscale/bytes".path;
        };
        
        users.byteshaker.enable = false;
        local-networking.enable = false;
    };

    system.stateVersion = "25.05";
}
