{ inputs, ... }: {
    flake.nixosModules.hostBytesProxmox = { lib, pkgs, ... }: let
        system = pkgs.stdenv.hostPlatform.system;
    in {
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
            inputs.proxmox-nixos.overlays.${system}
        ];
        
        services.openssh.settings.AcceptEnv = lib.mkForce null;
    };
}