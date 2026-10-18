{ inputs, ... }: {
    flake.nixosModules.base = { pkgs, ... }: {
        nixpkgs.config.allowUnfree = true;
    };
}
