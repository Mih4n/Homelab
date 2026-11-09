{ self, ... }: let
    s = self.settings;
in {
    flake.nixosModules.hostVpnHeadplane = { config, ... }: let
        secrets = config.sops.secrets;
        headscaleUser = config.services.headscale.user;
    in {
        # Declared here, not in the shared sops module: the headscale user only exists on this host.
        sops.secrets."headplane/cookie-secret".owner = headscaleUser;
        sops.secrets."headplane/api-key".owner = headscaleUser;
        sops.secrets."headplane/oidc-client-secret".owner = headscaleUser;

        services.headplane = {
            enable = true;
            settings = {
                server = {
                    port = s.ports.headplane;
                    base_url = "https://${s.domains.vpn}";
                    cookie_secret_path = secrets."headplane/cookie-secret".path;
                };
                headscale.api_key_path = secrets."headplane/api-key".path;
                oidc = {
                    enabled = true;
                    issuer = "https://${s.domains.auth}/application/o/headplane/";
                    client_id = s.oidc.headplane.clientId;
                    client_secret_path = secrets."headplane/oidc-client-secret".path;
                };
            };
        };
    };
}
