{ self, ... }: let
    s = self.settings;
in {
    flake.nixosModules.hostVpnTraefik = { config, ... }: {
        services.traefik = {
            enable = true;

            staticConfigOptions = {
                entryPoints = {
                    web = {
                        address = ":80";
                        asDefault = true;
                        http.redirections.entrypoint = {
                            to = "websecure";
                            scheme = "https";
                        };
                    };

                    websecure = {
                        address = ":443";
                        asDefault = true;
                        http.tls.certResolver = "letsencrypt";
                    };

                    gitssh.address = ":${toString s.ports.forgejoSsh}";
                };

                log = {
                    level = "INFO";
                    filePath = "${config.services.traefik.dataDir}/traefik.log";
                    format = "json";
                };

                certificatesResolvers.letsencrypt.acme = {
                    email = s.emails.acme;
                    storage = "${config.services.traefik.dataDir}/acme.json";
                    httpChallenge.entryPoint = "web";
                };

            };

            dynamicConfigOptions = {
                http.routers = {
                    home = {
                        rule = "Host(`${s.domains.home}`)";
                        tls.certResolver = "letsencrypt";
                        service = "homeassistant";
                        entrypoints = "websecure";
                    };
                    headscale = {
                        rule = "Host(`${s.domains.vpn}`)";
                        tls.certResolver = "letsencrypt";
                        service = "headscale";
                        entrypoints = "websecure";
                    };
                    # Longer rule wins over the plain headscale router, so /admin lands here.
                    headplane = {
                        rule = "Host(`${s.domains.vpn}`) && PathPrefix(`/admin`)";
                        tls.certResolver = "letsencrypt";
                        service = "headplane";
                        entrypoints = "websecure";
                    };
                    nextcloud = {
                        rule = "Host(`${s.domains.cloud}`)";
                        entrypoints = "websecure";
                        middlewares = ["nextcloud-redirectregex"];
                        service = "nextcloud";
                        tls.certResolver = "letsencrypt";
                    };
                    # Webhooks, forms and the public API must stay reachable
                    # without an Authentik session.
                    n8n-public = {
                        rule = "Host(`${s.domains.n8n}`) && (PathPrefix(`/webhook`) || PathPrefix(`/api/v1`) || PathPrefix(`/form`) || PathPrefix(`/healthz`))";
                        tls.certResolver = "letsencrypt";
                        service = "n8n";
                        entrypoints = "websecure";
                        priority = 100;
                    };
                    # The outpost callback and start endpoints must be served
                    # by Authentik itself, not by n8n.
                    n8n-outpost = {
                        rule = "Host(`${s.domains.n8n}`) && PathPrefix(`/outpost.goauthentik.io`)";
                        tls.certResolver = "letsencrypt";
                        service = "authentik-outpost";
                        entrypoints = "websecure";
                        priority = 200;
                    };
                    n8n = {
                        rule = "Host(`${s.domains.n8n}`)";
                        tls.certResolver = "letsencrypt";
                        service = "n8n";
                        entrypoints = "websecure";
                        middlewares = [ "authentik" ];
                        priority = 10;
                    };
                    proxmox = {
                        rule = "Host(`${s.domains.proxmox}`)";
                        tls.certResolver = "letsencrypt";
                        service = "proxmox";
                        entrypoints = "websecure";
                    };
                    auth = {
                        rule = "Host(`${s.domains.auth}`)";
                        tls.certResolver = "letsencrypt";
                        service = "auth";
                        entrypoints = "websecure";
                        middlewares = [ "auth-headers" ];
                    };
                    takeapunch = {
                        rule = "Host(`${s.domains.takeapunch}`)";
                        tls.certResolver = "letsencrypt";
                        service = "takeapunch";
                        entrypoints = "websecure";
                    };
                    portfolio = {
                        rule = "Host(`${s.domains.root}`)";
                        tls.certResolver = "letsencrypt";
                        service = "portfolio";
                        entrypoints = "websecure";
                    };
                    git = {
                        rule = "Host(`${s.domains.git}`)";
                        tls.certResolver = "letsencrypt";
                        service = "git";
                        entrypoints = "websecure";
                    };
                };

                http.middlewares = {
                    nextcloud-redirectregex.redirectRegex = {
                        permanent = true;
                        regex = "https://(.*)/.well-known/(?:card|cal)dav";
                        replacement = "https://\${1}/remote.php/dav";
                    };
                    auth-headers.headers.customRequestHeaders = {
                        "X-Forwarded-Proto" = "https";
                        "X-Forwarded-Port" = "443";
                    };
                    authentik.forwardAuth = {
                        address = "http://127.0.0.1:9005/outpost.goauthentik.io/auth/traefik";
                        trustForwardHeader = true;
                        authResponseHeaders = [
                            "X-authentik-username"
                            "X-authentik-groups"
                            "X-authentik-email"
                            "X-authentik-name"
                            "X-authentik-uid"
                            "X-authentik-jwt"
                            "X-authentik-meta-jwks"
                            "X-authentik-meta-outpost"
                            "X-authentik-meta-provider"
                            "X-authentik-meta-app"
                            "X-authentik-meta-version"
                        ];
                    };
                };

                http.services = {
                    auth.loadBalancer.servers = [{ url = "http://${s.hosts.bytes}:9000"; }];
                    proxmox.loadBalancer = {
                        servers = [{ url = "https://${s.hosts.bytes}:8006"; }];
                        serversTransport = "proxmox-transport";
                    };
                    git.loadBalancer.servers = [{ url = "http://${s.hosts.git}:${toString s.ports.forgejoHttp}"; }];
                    headscale.loadBalancer.servers = [{ url = "http://localhost:${toString s.ports.headscale}"; }];
                    headplane.loadBalancer.servers = [{ url = "http://localhost:${toString s.ports.headplane}"; }];
                    authentik-outpost.loadBalancer.servers = [{ url = "http://127.0.0.1:9005"; }];
                    nextcloud.loadBalancer.servers = [{ url = "http://${s.hosts.nextcloud}:80"; }];
                    n8n.loadBalancer.servers = [{ url = "http://${s.hosts.n8n}:${toString s.ports.n8n}"; }];
                    portfolio.loadBalancer.servers = [{ url = "http://${s.hosts.polygon}:3002"; }];
                    takeapunch.loadBalancer.servers = [{ url = "http://${s.hosts.polygon}:3001"; }];
                    homeassistant.loadBalancer.servers = [{ url = "http://${s.net.ips.homeassistant}:8123"; }];
                };

                http.serversTransports.proxmox-transport = {
                    insecureSkipVerify = true;
                };

                # HostSNI(`*`) - обязательный catch-all для TCP-роутера без TLS:
                # в голом SSH нет SNI, поэтому различать хосты можно только по порту.
                tcp.routers.git-ssh = {
                    rule = "HostSNI(`*`)";
                    service = "git-ssh";
                    entrypoints = "gitssh";
                };

                tcp.services.git-ssh.loadBalancer.servers = [{ address = "${s.hosts.git}:22"; }];
            };
        };

        networking.firewall.allowedTCPPorts = [ s.ports.forgejoSsh ];
    };
}
