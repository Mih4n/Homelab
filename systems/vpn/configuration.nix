{ inputs, ... }: {
    imports = [ 
        inputs.disko.nixosModules.default
        inputs.sops-nix.nixosModules.sops

        ./modules

        ../.modules
        ../.modules/kernel/disko/standard.nix

        ./hardware-configuration.nix
    ];

    bytes = {
        disk.type = "vda";
        boot.mode = "legacy-grub";

        vscode.enable = true;
    }; 
 
    system.stateVersion = "25.05";
}