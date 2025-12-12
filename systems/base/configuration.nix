{ modulesPath, system, inputs, ... }: {
    imports = [
        inputs.disko.nixosModules.default

        "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"

        ../.modules
        ../.modules/kernel/disko/standard.nix

        ./hardware-configuration.nix
    ];

    nix.settings.trusted-users = [ "root" "@wheel" "byteshaker" ];

    nixpkgs.hostPlatform = system;
}