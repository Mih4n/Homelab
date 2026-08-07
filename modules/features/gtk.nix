{ inputs, ... }: {
    flake.nixosModules.gtk = { pkgs, lib, ... }: let
        theme-name = "Gruvbox-Teal-Dark-Medium";

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
        imports = [
            inputs.stylix.nixosModules.stylix
        ];

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

        stylix = {
            enable = true;
            base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
            targets = {
                grub.enable = false;
            };
        };

        environment.sessionVariables = {
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
            icon-theme-package
            cursor-theme-package

            pkgs.gtk3
            pkgs.gtk4
        ];
    };
}