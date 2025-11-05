{ system, inputs, ... }: {
    services.proxmox-ve = {
        enable = true;
        bridges = [ 
            "vmbr0" 
            # "vmbr1" 
        ];
        ipAddress = "192.168.0.2";
    };

    nixpkgs.overlays = [
        inputs.proxmox-nixos.overlays.${system}
    ];

    # environment.persistence."/persistent".directories = [
    #     "/var/lib/pve-cluster"
    # ];
}
