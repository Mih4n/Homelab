{ system, inputs, ... }: {
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
}
