{ inputs, self, ... }: {
    perSystem = { pkgs, ... }: {
        packages.noctaliaShell = let 
            p = self.palette;
        in inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
            inherit pkgs;

            settings = (builtins.fromJSON (builtins.readFile ./settings.json)).settings;

            package = pkgs.noctalia-shell.overrideAttrs (old: {
                name = "noctalia-wrapped";
            });

            env = {
                # Not /tmp: the chosen wallpaper lives in shell-state.json here,
                # and /tmp is wiped on every boot.
                "NOCTALIA_CACHE_DIR" = "/home/mih4n/.local/state/noctalia/";
            };

            colors = {
                mError = p.red;
                mHover = p.fg_muted;
                mOnError = p.bg;
                mOnHover = p.bg;
                mOnPrimary = p.bg;
                mOnSecondary = p.bg;
                mOnSurface = p.fg_bright; 
                mOnSurfaceVariant = p.fg;
                mOnTertiary = p.bg;
                mOutline = p.bg_med;
                mPrimary = p.blue;
                mSecondary = p.gray;
                mShadow = p.bg;
                mSurface = p.bg;
                mSurfaceVariant = p.bg;
                mTertiary = p.green;
            };
        };
    };
}