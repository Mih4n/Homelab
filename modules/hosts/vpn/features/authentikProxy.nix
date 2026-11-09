{ self, inputs, ... }: let
    s = self.settings;
in {
    flake.nixosModules.hostVpnAuthentikProxy = { config, ... }: {
        imports = [
            inputs.authentik.nixosModules.default
        ];

        sops.secrets."n8n/authentik-outpost-token" = {};

        sops.templates."authentik-proxy.env".content = ''
            AUTHENTIK_HOST=https://${s.domains.auth}
            AUTHENTIK_TOKEN=${config.sops.placeholder."n8n/authentik-outpost-token"}
        '';

        services.authentik-proxy = {
            enable = true;
            listenHTTP = "127.0.0.1:9005";
            environmentFile = config.sops.templates."authentik-proxy.env".path;
        };

        # The outpost reads its token only at startup; restart it when the
        # rendered environment file changes.
        systemd.services.authentik-proxy.restartTriggers = [
            config.sops.templates."authentik-proxy.env".path
        ];
    };
}
