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
                    nextcloud = {
                        rule = "Host(`${s.domains.cloud}`)";
                        entrypoints = "websecure";
                        middlewares = ["nextcloud-redirectregex"];
                        service = "nextcloud";
                        tls.certResolver = "letsencrypt";
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
                };

                http.services = {
                    auth.loadBalancer.servers = [{ url = "http://${s.hosts.bytes}:9000"; }];
                    proxmox.loadBalancer = {
                        servers = [{ url = "https://${s.hosts.bytes}:8006"; }];
                        serversTransport = "proxmox-transport";
                    };
                    git.loadBalancer.servers = [{ url = "http://${s.hosts.git}:${toString s.ports.forgejoHttp}"; }];
                    headscale.loadBalancer.servers = [{ url = "http://localhost:${toString s.ports.headscale}"; }];
                    nextcloud.loadBalancer.servers = [{ url = "http://${s.hosts.nextcloud}:80"; }];
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
