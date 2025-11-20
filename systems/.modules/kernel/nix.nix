{ inputs, ... }: {
    nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
}