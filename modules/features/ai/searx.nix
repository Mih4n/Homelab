{ self, ... }: let
    s = self.settings;
in {
    flake.nixosModules.searx = { config, pkgs, ... }: let
        engines = [
            # web
            "google"
            "duckduckgo"
            "brave"
            "wikipedia"
            "yandex"

            # science, for references
            "arxiv"
            "google scholar"
            "semantic scholar"
            "crossref"

            # code
            "github"
            "stackoverflow"
            "nixos wiki"
            "mdn"
        ];
    in {
        sops.secrets."searx/secret-key" = {};
        sops.templates."searx.env".content = ''
            SEARX_SECRET_KEY=${config.sops.placeholder."searx/secret-key"}
        '';

        services.searx = {
            enable = true;
            package = pkgs.searxng;
            environmentFile = config.sops.templates."searx.env".path;

            settings = {
                use_default_settings.engines.keep_only = engines;

                engines = map (name: { inherit name; disabled = false; }) engines;

                server = {
                    bind_address = "0.0.0.0";
                    port = s.ports.searx;
                    secret_key = "$SEARX_SECRET_KEY";
                    limiter = false;
                };

                search = {
                    formats = [ "html" "json" ];
                    safe_search = 0;
                };
            };
        };
    };
}
