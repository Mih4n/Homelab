{
    imports = [ 
        ../.modules

        ../.modules/kernel/disko/standard.nix

        ./hardware-configuration.nix
    ];

    system.stateVersion = "25.05";
}