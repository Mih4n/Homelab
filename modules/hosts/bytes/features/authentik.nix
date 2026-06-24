{ inputs, ... }: {
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
                    from = "bytes@mih4n.xyz";
                    username = "bytes";

                    port = 465;
                    use_tls = true;
                    use_ssl = false;
                };
                disable_startup_analytics = true;
                avatars = "initials";
            };
        };
    };
}