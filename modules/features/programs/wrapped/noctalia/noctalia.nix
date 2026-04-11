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
                "NOCTALIA_CACHE_DIR" = "/tmp/noctalia-wrapped-cache/";
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