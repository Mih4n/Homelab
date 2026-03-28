{ ... }: {
    flake.nixosModules.noPasswordSudo = { ... }: {
        security.sudo = {
            enable = true;
            wheelNeedsPassword = false;
        };
    };
}