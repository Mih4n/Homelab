{ inputs, self, ... }: {
    perSystem = { pkgs, lib, ... }: {
        packages.noctaliaShell = let
            p = self.palette;
            f = self.fonts;

            portfolio = {
                ui = {
                    fontDefault = f.ui;
                    fontFixed = f.mono;
                };
            };

            json = (builtins.fromJSON (builtins.readFile ./settings.json)).settings;
        in inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
            inherit pkgs;

            settings = lib.recursiveUpdate json portfolio;

            package = pkgs.noctalia-shell.overrideAttrs (old: {
                name = "noctalia-wrapped";
            });

            preInstalledPlugins = {
                # Replaces polkit-gnome, don't run another agent next to it.
                polkit-agent.src = "${inputs.noctalia-plugins}/polkit-agent";
                mpvpaper.src = "${inputs.noctalia-plugins}/mpvpaper";
            };

            # The plugin puts its default "~/Pictures/Wallpapers" into a file://
            # url as is, without expanding ~, and finds no videos there.
            pluginSettings.mpvpaper.wallpapersFolder = json.wallpaper.directory;

            plugins = {
                version = 2;
                sources = [
                    {
                        enabled = true;
                        name = "Noctalia Plugins";
                        url = "https://github.com/noctalia-dev/noctalia-plugins";
                    }
                ];
            };

            # mpvpaper plays the wallpaper, ffmpeg makes its thumbnails.
            runtimePkgs = with pkgs; [ mpvpaper ffmpeg ];

            env = {
                # Not /tmp: the chosen wallpaper lives in shell-state.json here,
                # and /tmp is wiped on every boot.
                "NOCTALIA_CACHE_DIR" = "/home/mih4n/.local/state/noctalia/";
            };

            # Neutral surfaces, thin borders, the darker bg on hover and
            # light text over the accent fills, as on the portfolio.
            colors = {
                mError = p.bright_red;
                mHover = p.bg_hard;
                mOnError = p.bg;
                mOnHover = p.fg_bright;
                mOnPrimary = p.on_accent;
                mOnSecondary = p.on_accent;
                mOnSurface = p.fg_bright;
                mOnSurfaceVariant = p.fg;
                mOnTertiary = p.on_accent;
                mOutline = p.border;
                mPrimary = p.blue;
                mSecondary = p.aqua;
                mShadow = p.bg_hard;
                mSurface = p.bg;
                mSurfaceVariant = p.bg;
                mTertiary = p.green;
            };
        };
    };
}
