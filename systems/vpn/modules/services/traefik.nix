{ config, ... }: {
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
                email = "imih4ni@gmail.com";
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
            };
            http.middlewares = {
                nextcloud-redirectregex.redirectRegex = {
                    permanent = true;
                    regex = "https://(.*)/.well-known/(?:card|cal)dav";
                    replacement = "https://\${1}/remote.php/dav";
                };
            };
            http.services = {
                homeassistant.loadBalancer.servers = [
                    {
                        url = "http://192.168.192.10:8123";
                    }
                ];
                headscale.loadBalancer.servers = [
                    {
                        url = "http://localhost:3009";
                    }
                ];
                nextcloud.loadBalancer.servers = [
                    {
                        url = "http://100.64.0.8:80";
                    }
                ];
            };
        };
    };
}