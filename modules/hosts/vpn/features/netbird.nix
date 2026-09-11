{ ... }: {
    flake.nixosModules.hostVpnNetbird = { config, ... }: let
        domain = "netbird.mih4n.xyz";
        authIssuer = "https://auth.mih4n.xyz/application/o/netbird/";
    in {
        services.netbird.server = {
            enable = true;
            domain = domain;

            coturn = {
                enable = true;
                passwordFile = config.sops.secrets."netbird/turn-password".path;
            };

            management = {
                oidcConfigEndpoint = "${authIssuer}.well-known/openid-configuration";

                settings = {
                    DataStoreEncryptionKey._secret = config.sops.secrets."netbird/data-store-encryption-key".path;
                    TURNConfig.Secret._secret = config.sops.secrets."netbird/turn-secret".path;
                };
            };

            # served through the vpn host's traefik instead of netbird's own nginx,
            # except for the static dashboard bundle, which still needs a file server
            dashboard.enableNginx = true;
            dashboard.settings = {
                AUTH_AUTHORITY = authIssuer;
                AUTH_CLIENT_ID = "netbird";
                AUTH_SUPPORTED_SCOPES = "openid profile email";
            };
        };

        # dashboard's nginx only serves static files; keep it off the public interface,
        # traefik terminates TLS and proxies to it on the loopback
        services.nginx.virtualHosts.${domain}.listen = [
            { addr = "127.0.0.1"; port = 8095; }
        ];
    };
}
