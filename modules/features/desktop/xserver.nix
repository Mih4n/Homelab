{ ... }: {
    flake.nixosModules.xserver = { ... }: {
        services.xserver.enable = true;
        services.xserver.xkb = {
            layout = "us,ru";
            variant = "";
        };
    };
}