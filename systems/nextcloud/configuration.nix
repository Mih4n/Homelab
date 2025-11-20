{
    imports = [
        ./modules/services

        ../.modules/users
        ../.modules/kernel
        ../.modules/packages
        ../.modules/programs

        ../.modules/kernel/disko/standard.nix
    ];

    system.stateVersion = "25.05";
}