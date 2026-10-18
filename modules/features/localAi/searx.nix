{ ... }: {
    flake.nixosModules.localAiSearx = { lib, config, pkgs, ... }: let
        cfg = config.bytes.localAi;

        # Everything else is dropped: fewer engines, less noise in the
        # results the model has to read.
        engines = [
            # web
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
    in lib.mkIf cfg.server {
        sops.secrets."searx/secret-key" = { };
        sops.templates."searx.env".content = ''
            SEARX_SECRET_KEY=${config.sops.placeholder."searx/secret-key"}
        '';

        services.searx = {
            enable = true;
            package = pkgs.searxng;
            environmentFile = config.sops.templates."searx.env".path;

            settings = {
                use_default_settings.engines.keep_only = engines;

                # Some of them are disabled upstream, keep_only does not enable them.
                engines = map (name: { inherit name; disabled = false; }) engines;

                server = {
                    bind_address = "0.0.0.0";
                    port = cfg.searxPort;
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
