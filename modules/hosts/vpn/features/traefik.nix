{ ... }: {
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
                };

                log = {
                    level = "INFO";
                    filePath = "${config.services.traefik.dataDir}/traefik.log";
                    format = "json";
                };

                certificatesResolvers.letsencrypt.acme = {
                    email = "lmih4nl@gmail.com";
                    storage = "${config.services.traefik.dataDir}/acme.json";
                    httpChallenge.entryPoint = "web";
                };

            };

            dynamicConfigOptions = {
                http.routers = {
                    home = {
                        rule = "Host(`home.mih4n.xyz`)";
                        tls.certResolver = "letsencrypt";
                        service = "homeassistant";
                        entrypoints = "websecure";
                    };
                    headscale = {
                        rule = "Host(`vpn.mih4n.xyz`)";
                        tls.certResolver = "letsencrypt";
                        service = "headscale";
                        entrypoints = "websecure";
                    };
                    netbird-signal = {
                        rule = "Host(`netbird.mih4n.xyz`) && PathPrefix(`/signalexchange.SignalExchange/`)";
                        tls.certResolver = "letsencrypt";
                        service = "netbird-signal";
                        entrypoints = "websecure";
                    };
                    netbird-management-grpc = {
                        rule = "Host(`netbird.mih4n.xyz`) && PathPrefix(`/management.ManagementService/`)";
                        tls.certResolver = "letsencrypt";
                        service = "netbird-management";
                        entrypoints = "websecure";
                    };
                    netbird-management-api = {
                        rule = "Host(`netbird.mih4n.xyz`) && PathPrefix(`/api`)";
                        tls.certResolver = "letsencrypt";
                        service = "netbird-management";
                        entrypoints = "websecure";
                    };
                    netbird-dashboard = {
                        rule = "Host(`netbird.mih4n.xyz`)";
                        tls.certResolver = "letsencrypt";
                        service = "netbird-dashboard";
                        entrypoints = "websecure";
                    };
                    nextcloud = {
                        rule = "Host(`cloud.mih4n.xyz`)";
                        entrypoints = "websecure";
                        middlewares = ["nextcloud-redirectregex"];
                        service = "nextcloud";
                        tls.certResolver = "letsencrypt";
                    };
                    proxmox = {
                        rule = "Host(`proxmox.mih4n.xyz`)";
                        tls.certResolver = "letsencrypt";
                        service = "proxmox";
                        entrypoints = "websecure";
                    };
                    auth = {
                        rule = "Host(`auth.mih4n.xyz`)";
                        tls.certResolver = "letsencrypt";
                        service = "auth";
                        entrypoints = "websecure";
                    };
                    takeapunch = {
                        rule = "Host(`takeapunch.mih4n.xyz`)";
                        tls.certResolver = "letsencrypt";
                        service = "takeapunch";
                        entrypoints = "websecure";
                    };
                    portfolio = {
                        rule = "Host(`mih4n.xyz`)";
                        tls.certResolver = "letsencrypt";
                        service = "portfolio";
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
                    auth.loadBalancer.servers = [{ url = "http://bytes.bytes:9000"; }];
                    proxmox.loadBalancer = {
                        servers = [{ url = "https://bytes.bytes:8006"; }];
                        serversTransport = "proxmox-transport";
                    };
                    headscale.loadBalancer.servers = [{ url = "http://localhost:3009"; }];
                    netbird-signal.loadBalancer.servers = [{ url = "h2c://127.0.0.1:8012"; }];
                    netbird-management.loadBalancer.servers = [{ url = "h2c://127.0.0.1:8011"; }];
                    netbird-dashboard.loadBalancer.servers = [{ url = "http://127.0.0.1:8095"; }];
                    nextcloud.loadBalancer.servers = [{ url = "http://nextcloud.bytes:80"; }];
                    portfolio.loadBalancer.servers = [{ url = "http://polygon.bytes:3002"; }];
                    takeapunch.loadBalancer.servers = [{ url = "http://polygon.bytes:3001"; }];
                    homeassistant.loadBalancer.servers = [{ url = "http://192.168.192.10:8123"; }];
                };

                http.serversTransports.proxmox-transport = {
                    insecureSkipVerify = true;
                };
            };
        };
    };
}