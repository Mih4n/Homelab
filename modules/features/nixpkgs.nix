{ inputs, ... }: {
    flake.nixosModules.base = { pkgs, ... }: {
        nixpkgs.config.allowUnfree = true;
        # nixpkgs.overlays = [ inputs.millennium.overlays.default ];
        nixpkgs.config.permittedInsecurePackages = [
            "electron-40.10.5"
        ];
    };
}