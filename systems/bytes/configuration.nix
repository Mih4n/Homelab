{ inputs, lib, config, ... }: {
    imports = [
        inputs.disko.nixosModules.default
        inputs.sops-nix.nixosModules.sops
        inputs.authentik.nixosModules.default
        inputs.vscode-server.nixosModules.default
        inputs.proxmox-nixos.nixosModules.proxmox-ve

        ./modules/kernel
        ./modules/services

        ../.modules/users
        ../.modules/kernel
        ../.modules/packages
        ../.modules/programs

        ../.modules/kernel/disko/standard.nix
    ];

    bytes.users.byteshaker.enable = false;

    system.stateVersion = "25.05";

    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
