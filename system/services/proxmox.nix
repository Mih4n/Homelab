{ system, inputs, ... }: {
    services.proxmox-ve = {
        enable = true;
        ipAddress = "192.168.0.2";
    };

    nixpkgs.overlays = [
        inputs.proxmox-nixos.overlays.${system}
    ];
}