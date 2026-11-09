{ inputs, self, ... }: let
    s = self.settings;
in {
    flake.nixosModules.authentik = { config, ... }: {
        imports = [
            inputs.authentik.nixosModules.default
        ];

        services.authentik = {
            enable = true;
            environmentFile = config.sops.templates."authentik.env".path;
            settings = {
                email = {
                    host = "smtp.hoster.by";
                    from = s.emails.authentik;
                    username = "bytes";

                    port = 465;
                    use_tls = true;
                    use_ssl = false;
                };
                disable_startup_analytics = true;
                avatars = "initials";
                listen.trusted_proxy_cidrs = [
                    "127.0.0.0/8"
                    "10.0.0.0/8"
                    "172.16.0.0/12"
                    "192.168.0.0/16"
                    "fe80::/10"
                    "::1/128"
                    "100.64.0.0/10"
                ];
            };
        };
    };
}