{ inputs, ... }: {
    imports = [ 
        inputs.disko.nixosModules.default
        inputs.sops-nix.nixosModules.sops

        ./modules

        ../.modules
        ../.modules/kernel/disko/standard.nix
    ];

    bytes = {
        disk.type = "vda";
        boot.mode = "legacy-grub";
    }; 
 
    system.stateVersion = "25.05";
}