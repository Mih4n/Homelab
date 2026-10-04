{ inputs, self, ... }: {
    flake.nixosModules.stylix = { pkgs, config, ... }: let
        p = self.paletteNoHash;
        f = self.fonts;
        cursor = config.stylix.cursor;
    in {
        imports = [
            inputs.stylix.nixosModules.stylix
        ];

        stylix = {
            enable = true;
            polarity = "dark";

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

            fonts = {
                monospace = {
                    name = f.mono;
                    package = pkgs.nerd-fonts.jetbrains-mono;
                };
                sizes = {
                    applications = f.size;
                    desktop = f.size;
                };
            };

            cursor = {
                name = "capitaine-cursors";
                package = pkgs.capitaine-cursors;
                size = 24;
            };

            icons = {
                enable = true;
                package = pkgs.gruvbox-plus-icons;
                dark = "Gruvbox-Plus-Dark";
                light = "Gruvbox-Plus-Dark";
            };

            targets = {
                grub.enable = false;
                # Qt is themed through kdeglobals instead, see qt.nix.
                qt.enable = false;
            };
        };

        environment = {
            etc."icons/default/index.theme".text = ''
                [Icon Theme]
                Inherits=${cursor.name}
            '';

            sessionVariables.XCURSOR_THEME = cursor.name;

            systemPackages = [
                cursor.package
                config.stylix.icons.package
            ];
        };
    };
}
