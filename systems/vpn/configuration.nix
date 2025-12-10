{ inputs, ... }: {
    imports = [ 
        inputs.disko.nixosModules.default
        inputs.sops-nix.nixosModules.sops

        ./modules

        ../.modules
        ../.modules/kernel/disko/standard.nix

        ./hardware-configuration.nix
    ];

    bytes = {};
 
    system.stateVersion = "25.05";
}