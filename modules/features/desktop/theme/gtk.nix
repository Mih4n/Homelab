{ inputs, self, ... }: {
    flake.nixosModules.gtk = { pkgs, lib, config, ... }: let
        c = self.palette;
        f = self.fonts;

        inherit (config.stylix) cursor;
        icon-theme-name = config.stylix.icons.dark;

        # adw-gtk3 is the base theme stylix itself uses: it reads the
        # named colors below instead of shipping its own fixed palette.
        gtk-theme-name = "adw-gtk3";
        gtk-theme-package = pkgs.adw-gtk3;

        # Same gtk.css stylix's own home-manager gtk target renders,
        # generated straight from stylix's (palette.nix-derived) colors.
        # `colors` only recognizes a path/derivation as a template, so the
        # mustache file is copied into its own derivation first.
        gtkCssTemplate = pkgs.runCommandLocal "gtk-css-template" {} ''
            cp ${inputs.stylix}/modules/gtk/gtk.css.mustache $out
        '';

        stylixCss = config.lib.stylix.colors {
            template = gtkCssTemplate;
            extension = ".css";
        };

        # The portfolio look on top of stylix's colors: neutral surfaces split
        # by thin borders, the darker bg only on hover, and the muted blue as
        # the accent fill with light text over it.
        portfolioCss = pkgs.writeText "gtk-portfolio.css" ''
            @define-color accent_color ${c.bright_blue};
            @define-color accent_bg_color ${c.blue};
            @define-color accent_fg_color ${c.on_accent};
            @define-color headerbar_border_color ${c.border};
            @define-color sidebar_border_color ${c.border};
            @define-color borders ${c.border};
            @define-color unfocused_borders ${c.border};
            @define-color scrollbar_outline_color ${c.border_strong};
            @define-color view_hover_bg_color ${c.bg_hard};
        '';

        gtkCss = pkgs.runCommandLocal "gtk.css" {} ''
            cat ${stylixCss} ${portfolioCss} > $out
        '';

        gtksettings = ''
            [Settings]
            gtk-theme-name = ${gtk-theme-name}
            gtk-icon-theme-name = ${icon-theme-name}
            gtk-cursor-theme-name = ${cursor.name}
            gtk-cursor-theme-size = ${toString cursor.size}
            gtk-font-name = ${f.ui} ${toString f.size}
            gtk-application-prefer-dark-theme = true
        '';
        gtksettingsFile = pkgs.writeText "gtk-settings.ini" gtksettings;
    in {
        imports = [
            self.nixosModules.stylix
        ];

        environment.etc = {
            "xdg/gtk-3.0/settings.ini".text = gtksettings;
            "xdg/gtk-4.0/settings.ini".text = gtksettings;
            "xdg/gtk-3.0/gtk.css".source = gtkCss;
            "xdg/gtk-4.0/gtk.css".source = gtkCss;
        };

        # GTK reads gtk.css only from ~/.config, and a settings.ini there fully
        # shadows the one in /etc/xdg, so the files above alone were ignored
        # (old KDE-written ones won). Link the generated ones into every home
        # on login, replacing whatever is there.
        systemd.user.tmpfiles.rules = lib.concatMap (dir: [
            "L+ %h/.config/${dir}/gtk.css - - - - ${gtkCss}"
            "L+ %h/.config/${dir}/settings.ini - - - - ${gtksettingsFile}"
        ]) [ "gtk-3.0" "gtk-4.0" ];

        programs = {
            dconf = {
                enable = lib.mkDefault true;
                profiles = {
                    user = {
                        databases = [
                            {
                                # Locked, otherwise stale values in the user's
                                # own dconf db (gtk-theme='', Noto Sans) win.
                                lockAll = true;
                                settings = {
                                    "org/gnome/desktop/interface" = {
                                        gtk-theme = gtk-theme-name;
                                        icon-theme = icon-theme-name;
                                        cursor-theme = cursor.name;
                                        cursor-size = lib.gvariant.mkInt32 cursor.size;
                                        color-scheme = "prefer-dark";
                                        accent-color = "teal";
                                        font-name = "${f.ui} ${toString f.size}";
                                        document-font-name = "${f.ui} ${toString f.size}";
                                        monospace-font-name = "${f.mono} ${toString f.size}";
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

            pkgs.gtk3
            pkgs.gtk4
        ];
    };
}
