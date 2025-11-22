{ inputs, ... }: {
    imports = [
        inputs.sops-nix.nixosModules.sops
        inputs.authentik.nixosModules.default
        inputs.vscode-server.nixosModules.default
        inputs.proxmox-nixos.nixosModules.proxmox-ve

        ./modules/kernel
        ./modules/services
        ./modules/packages

        ../.modules/users
        ../.modules/kernel
        ../.modules/packages
        ../.modules/programs
        ./hardware-configuration.nix
    ];

    bytes = {
        users.byteshaker.enable = false;
        local-networking.enable = false;
    };

    system.stateVersion = "25.05";
}
