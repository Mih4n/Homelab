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
                    proxmox.loadBalancer.servers = [{ 
                        url = "http://bytes.bytes:8006"; 
                        serversTransport = "proxmox-transport";
                    }];
                    headscale.loadBalancer.servers = [{ url = "http://localhost:3009"; }];
                    nextcloud.loadBalancer.servers = [{ url = "http://nextcloud.bytes:80"; }];
                    homeassistant.loadBalancer.servers = [{ url = "http://192.168.192.10:8123"; }];
                };

                http.serversTransports.proxmox-transport = {
                    insecureSkipVerify = true;
                };
            };
        };
    };
}