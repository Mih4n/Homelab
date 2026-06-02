{ inputs, ... }: {
    flake.nixosModules.hostBytesProxmox = { lib, ... }: {
        imports = [
            inputs.proxmox-nixos.nixosModules.proxmox-ve
        ];

        services.proxmox-ve = {
            enable = true;
            bridges = [ 
                "vmbr0" 
                "vmbrlo"
            ];
            ipAddress = "192.168.0.2";
        };

        nixpkgs.overlays = [
            inputs.proxmox-nixos.overlays.x86_64-linux
        ];
        
        services.openssh.settings.AcceptEnv = lib.mkForce null;
    };
}