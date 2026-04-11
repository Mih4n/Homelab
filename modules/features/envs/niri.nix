{ self, ... }: {
    flake.nixosModules.niriEnv = { pkgs, ... }: let 
        selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
    in {
        programs.niri = {
            enable = true;
            package = selfpkgs.niri;
        };

        xdg.portal = {
            enable = true;
            extraPortals = with pkgs; [
                xdg-desktop-portal-gtk
                kdePackages.xdg-desktop-portal-kde
            ];
            config.common = {
                default = [ "gtk" ];
                "org.freedesktop.impl.portal.FileChooser" = [ "kde" ];
            };
        };        

        environment.systemPackages = with pkgs; [
            kdePackages.polkit-kde-agent-1
        ];


        services = {
            gvfs.enable = true;
            udisks2.enable = true;
            hardware.openrgb.enable = true;
            flatpak.enable = true;
        };

        security.polkit.enable = true;

        environment.sessionVariables = {
            "NIXOS_OZON_WL" = "1";
            "QT_QPA_PLATFORM" = "wayland";
            "QT_QPA_PLATFORMTHEME" = "kde";
        };

        services.gnome.gnome-keyring.enable = true;
    };
}