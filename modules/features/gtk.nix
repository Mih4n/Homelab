{
    flake.nixosModules.gtk = { pkgs, lib, ... }: let
        theme-name = "Gruvbox-Teal-Dark-Medium";
        theme-package = pkgs.gruvbox-gtk-theme.override {
            colorVariants = ["dark"];
            sizeVariants = ["standard"];
            themeVariants = ["teal"];
            tweakVariants = ["medium"];
        };

        icon-theme-name = "Gruvbox-Plus-Dark";
        icon-theme-package = pkgs.gruvbox-plus-icons;

        cursor-theme-name = "capitaine-cursors";
        cursor-theme-package = pkgs.capitaine-cursors;

        gtksettings = ''
            [Settings]
            gtk-theme-name = ${theme-name}
            gtk-icon-theme-name = ${icon-theme-name}
            gtk-cursor-theme-name = ${cursor-theme-name}
        '';
    in {
        environment = {
            etc = {
                "xdg/gtk-3.0/settings.ini".text = gtksettings;
                "xdg/gtk-4.0/settings.ini".text = gtksettings;
                "icons/default/index.theme".text = ''
                    [Icon Theme]
                    Inherits=${cursor-theme-name}
                '';
            };
        };

        environment.sessionVariables = {
            GTK_THEME = theme-name;
            QT_QPA_PLATFORMTHEME = "gtk3"; 
            
            XDG_DATA_DIRS = [
                "$XDG_DATA_DIRS"
                "${pkgs.gruvbox-plus-icons}/share"
            ];

            XCURSOR_SIZE = "24";
            XCURSOR_THEME = cursor-theme-name;
        };

        programs = {
            dconf = {
                enable = lib.mkDefault true;
                profiles = {
                    user = {
                        databases = [
                            {
                                lockAll = false;
                                settings = {
                                    "org/gnome/desktop/interface" = {
                                        gtk-theme = theme-name;
                                        icon-theme = icon-theme-name;
                                        cursor-theme = cursor-theme-name;
                                        color-scheme = "prefer-dark";
                                    };
                                };
                            }
                        ];
                    };
                };
            };
        };

        environment.systemPackages = [
            theme-package
            icon-theme-package
            cursor-theme-package

            pkgs.gtk3
            pkgs.gtk4
        ];
    };
}