{ ... }: {
    flake.nixosModules.hostVpnNetbird = { config, ... }: let
        domain = "netbird.mih4n.xyz";

        authDomain = "https://auth.mih4n.xyz";
        authIssuer = "${authDomain}/application/o/netbird/";
        authAuthorizeEndpoint = "${authDomain}/application/o/authorize/";
        authTokenEndpoint = "${authDomain}/application/o/token/";

        oidcClientId = "aKraceQ4fr5SalyFxaexZf2FViHaSSpd4VyLpMMP";
        oidcScopes = "openid profile email offline_access entitlements goauthentik.io/api";

        idpUsername = "netbird";
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

                    HttpConfig.AuthAudience = oidcClientId;

                    IdpManagerConfig = {
                        ManagerType = "authentik";

                        ClientConfig = {
                            Issuer = authIssuer;
                            TokenEndpoint = authTokenEndpoint;
                            ClientID = oidcClientId;
                            GrantType = "client_credentials";
                        };

                        ExtraConfig = {
                            Username = idpUsername;
                            Password._secret = config.sops.secrets."netbird/idp-service-account-password".path;
                        };
                    };

                    PKCEAuthorizationFlow.ProviderConfig = {
                        Audience = oidcClientId;
                        ClientID = oidcClientId;
                        AuthorizationEndpoint = authAuthorizeEndpoint;
                        TokenEndpoint = authTokenEndpoint;
                        Scope = oidcScopes;
                        RedirectURLs = [ "http://localhost:53000" ];
                        UseIDToken = false;
                        DisablePromptLogin = true;
                    };
                };
            };

            dashboard.enableNginx = true;
            dashboard.settings = {
                AUTH_AUTHORITY = authIssuer;
                AUTH_AUDIENCE = oidcClientId;
                AUTH_CLIENT_ID = oidcClientId;
                AUTH_SUPPORTED_SCOPES = oidcScopes;
            };
        };

        # dashboard's nginx only serves static files; keep it off the public interface,
        # traefik terminates TLS and proxies to it on the loopback
        services.nginx.virtualHosts.${domain}.listen = [
            { addr = "127.0.0.1"; port = 8095; }
        ];
    };
}
