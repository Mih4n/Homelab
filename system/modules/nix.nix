{ inputs, ... }: {
    nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    nixpkgs.config.allowUnfree = true;
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
}