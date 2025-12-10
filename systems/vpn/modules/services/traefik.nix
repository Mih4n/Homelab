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
                headscale = {
                    rule = "Host(`vpn.mih4n.xyz`)";
                    tls = {
                        certResolver = "letsencrypt";
                    };
                    service = "headscale";
                    entrypoints = "websecure";
                }; 
            };
            http.services = {
                headscale.loadBalancer.servers = [
                    {
                        url = "http://localhost:3009";
                    }
                ];
            };
        };
    };
}