{ inputs, ... }: {
    flake.nixosModules.nix = { ... }: {
        nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
        nix.settings.trusted-users = [ "root" "@wheel" "byteshaker" "mih4n" ];
        nix.settings.experimental-features = [ "nix-command" "flakes" ];

        nixpkgs.config.allowUnfree = true;
    }; 
}