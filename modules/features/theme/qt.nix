{ self, ... }: {
    flake.nixosModules.qt = { lib, pkgs, ... }: let
        c = self.palette;
        f = self.fonts;

        rgb = hex: lib.concatMapStringsSep "," (i:
            toString (lib.fromHexString (builtins.substring i 2 hex))
        ) [ 1 3 5 ];

        qtFont = name: "${name},${toString f.size},-1,5,400,0,0,0,0,0,0,0,0,0,0,1";

        colorGroup = bg: alt: {
            BackgroundNormal = rgb bg;
            BackgroundAlternate = rgb alt;
            ForegroundNormal = rgb c.fg;
            ForegroundActive = rgb c.fg_bright;
            ForegroundInactive = rgb c.fg_muted;
            ForegroundLink = rgb c.bright_blue;
            ForegroundVisited = rgb c.bright_purple;
            ForegroundNegative = rgb c.bright_red;
            ForegroundNeutral = rgb c.bright_yellow;
            ForegroundPositive = rgb c.bright_green;
            DecorationFocus = rgb c.blue;
            DecorationHover = rgb c.bright_blue;
        };

        effect = {
            ColorEffect = 0;
            ColorAmount = 0;
            ContrastEffect = 1;
            ContrastAmount = 0.5;
            IntensityEffect = 0;
            IntensityAmount = 0;
        };

        kdeglobals = lib.generators.toINI {} {
            General = {
                ColorScheme = "Portfolio";
                Name = "Portfolio";
                AccentColor = rgb c.blue;
                font = qtFont f.ui;
                menuFont = qtFont f.ui;
                toolBarFont = qtFont f.ui;
                smallestReadableFont = qtFont f.ui;
                fixed = qtFont f.mono;
            };

            WM = {
                font = qtFont f.ui;
                activeBackground = rgb c.bg;
                activeForeground = rgb c.fg;
                activeBlend = rgb c.blue;
                inactiveBackground = rgb c.bg;
                inactiveForeground = rgb c.fg_muted;
                inactiveBlend = rgb c.border;
            };

            KDE.widgetStyle = "Breeze";
            Icons.Theme = "Gruvbox-Plus-Dark";

            "ColorEffects:Disabled" = effect;
            "ColorEffects:Inactive" = effect // { ContrastAmount = 0; ContrastEffect = 0; };

            "Colors:Window" = colorGroup c.bg c.bg_soft;
            "Colors:View" = colorGroup c.bg c.bg_soft;
            "Colors:Header" = colorGroup c.bg c.bg_soft;
            "Colors:Button" = colorGroup c.bg_soft c.border;
            "Colors:Tooltip" = colorGroup c.bg_hard c.bg;
            "Colors:Complementary" = colorGroup c.bg_hard c.bg;
            "Colors:Selection" = colorGroup c.blue c.blue // {
                ForegroundNormal = rgb c.on_accent;
                ForegroundActive = rgb c.on_accent;
                ForegroundInactive = rgb c.fg;
            };
        };
    in {
        qt = {
            enable = true;
            platformTheme = "kde";
            style = "breeze";
        };

        # KConfig cascades ~/.config/kdeglobals over /etc/xdg/kdeglobals.
        environment.etc."xdg/kdeglobals".text = kdeglobals;
    };
}
