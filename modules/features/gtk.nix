{ inputs, self, ... }: {
    flake.nixosModules.gtk = { pkgs, lib, config, ... }: let
        p = self.paletteNoHash;

        base16Scheme = {
            scheme = "palette.nix";
            author = "mih4n";

            base00 = p.bg;
            base01 = p.bg;
            base02 = p.bg_sel;
            base03 = p.bg_med;
            base04 = p.fg_muted;
            base05 = p.fg;
            base06 = p.fg_bright;
            base07 = p.fg_bright;
            base08 = p.bright_red;
            base09 = p.bright_orange;
            base0A = p.bright_yellow;
            base0B = p.bright_green;
            base0C = p.bright_aqua;
            base0D = p.bright_blue;
            base0E = p.bright_purple;
            base0F = p.orange;
        };

        # adw-gtk3 is the base theme stylix itself uses: it reads the
        # named colors below instead of shipping its own fixed palette.
        gtk-theme-name = "adw-gtk3";
        gtk-theme-package = pkgs.adw-gtk3;

        icon-theme-name = "Gruvbox-Plus-Dark";
        icon-theme-package = pkgs.gruvbox-plus-icons;

        cursor-theme-name = "capitaine-cursors";
        cursor-theme-package = pkgs.capitaine-cursors;
        cursor-size = 24;

        # Same gtk.css stylix's own home-manager gtk target renders,
        # generated straight from stylix's (palette.nix-derived) colors.
        # `colors` only recognizes a path/derivation as a template, so the
        # mustache file is copied into its own derivation first.
        gtkCssTemplate = pkgs.runCommandLocal "gtk-css-template" {} ''
            cp ${inputs.stylix}/modules/gtk/gtk.css.mustache $out
        '';

        gtkCss = config.lib.stylix.colors {
            template = gtkCssTemplate;
            extension = ".css";
        };

        gtksettings = ''
            [Settings]
            gtk-theme-name = ${gtk-theme-name}
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
                "xdg/gtk-3.0/gtk.css".source = gtkCss;
                "xdg/gtk-4.0/gtk.css".source = gtkCss;
                "icons/default/index.theme".text = ''
                    [Icon Theme]
                    Inherits=${cursor-theme-name}
                '';
            };
        };

        stylix = {
            enable = true;
            inherit base16Scheme;

            cursor = {
                name = cursor-theme-name;
                package = cursor-theme-package;
                size = cursor-size;
            };

            icons = {
                enable = true;
                package = icon-theme-package;
                dark = icon-theme-name;
                light = icon-theme-name;
            };

            targets = {
                grub.enable = false;
            };
        };

        environment.sessionVariables = {
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
                                        gtk-theme = gtk-theme-name;
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
            gtk-theme-package
            icon-theme-package
            cursor-theme-package

            pkgs.gtk3
            pkgs.gtk4
        ];
    };
}
