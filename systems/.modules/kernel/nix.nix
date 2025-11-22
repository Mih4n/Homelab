{ inputs, ... }: {
    nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
    nix.settings.trusted-users = [ "root" "@wheel" "byteshaker" ];
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
}