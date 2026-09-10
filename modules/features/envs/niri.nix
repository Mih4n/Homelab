{ self, ... }: {
    flake.nixosModules.niriEnv = { pkgs, lib, ... }: let
        selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
    in {
        programs.niri = {
            enable = true;
            package = selfpkgs.niri;
            useNautilus = true;
        };

        xdg.portal = {
            enable = true;
            extraPortals = [
              pkgs.xdg-desktop-portal-gnome
            ];
            config.common.default = "*";
        };

        qt = {
            enable = true;
            platformTheme = lib.mkForce "gnome";
        };

        environment.systemPackages = [
            selfpkgs.niri
            selfpkgs.noctaliaShell
            pkgs.qgnomeplatform
        ];

        services = {
            gvfs.enable = true;
            udisks2.enable = true;
        };

        security.polkit.enable = true;

        environment.sessionVariables = {
            NIXOS_OZON_WL = "1";
            XDG_CURRENT_DESKTOP = "niri";
            QT_QPA_PLATFORMTHEME = "gnome";
        };

        services.gnome.gnome-keyring.enable = true;
    };
}
