{ ... }: {
    flake.nixosModules.qmk = { pkgs, ... }: {
        hardware.keyboard.qmk.enable = true;   

        services.udev.packages = [ pkgs.via ];
        environment.systemPackages = [ pkgs.via ];
    };
}