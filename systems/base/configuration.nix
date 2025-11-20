{ modulesPath, system, inputs, ... }: {
    imports = [
        inputs.disko.nixosModules.default

        "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"

        ../.modules/users
        ../.modules/kernel
        ../.modules/packages
        ../.modules/kernel/disko/standard.nix
    ];

    nixpkgs.hostPlatform = system;
}