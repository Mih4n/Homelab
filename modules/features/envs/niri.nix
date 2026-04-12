{ self, ... }: {
    flake.nixosModules.niriEnv = { pkgs, ... }: let 
        selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
    in {
        programs.niri = {
            enable = true;
            package = selfpkgs.niri;
            useNautilus = true;
        };

        xdg.portal = {
            enable = true;
            extraPortals = with pkgs; [
                xdg-desktop-portal-gtk
                kdePackages.xdg-desktop-portal-kde
            ];
            config.common = {
                default = [ "gtk" ];
            };
        };        

        environment.systemPackages = with pkgs; [
            selfpkgs.niri
            selfpkgs.noctaliaShell
        ];

        services = {
            gvfs.enable = true;
            udisks2.enable = true;
        };

        security.polkit.enable = true;

        environment.sessionVariables = {
            "NIXOS_OZON_WL" = "1";
        };

        services.gnome.gnome-keyring.enable = true;
    };
}
