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

                smtp = { address = ":25"; };
                submission = { address = ":587"; };
                smtps = { address = ":465"; };

                imap = { address = ":143"; };
                imaps = { address = ":993"; };

                pop3 = { address = ":110"; };
                pop3s = { address = ":995"; };
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
                mail = {
                    rule = "Host(`mail.mih4n.xyz`)";
                    service = "mail";
                    tls = {
                        passthrough = true;
                    };
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
            tcp = {
                routers = {
                    smtp = {
                        entryPoints = ["smtp"];
                        rule = "HostSNI(`*`)";
                        service = "smtp";
                    };

                    submission = {
                        entryPoints = ["submission"];
                        rule = "HostSNI(`mail.mih4n.xyz`)";
                        service = "submission";
                    };

                    smtps = {
                        entryPoints = ["smtps"];
                        rule = "HostSNI(`mail.mih4n.xyz`)";
                        service = "smtps";
                        tls = { passthrough = true; };
                    };

                    imaps = {
                        entryPoints = ["imaps"];
                        rule = "HostSNI(`mail.mih4n.xyz`)";
                        service = "imaps";
                        tls = { passthrough = true; };
                    };
                };

                services = {
                    smtp.loadBalancer.servers = [
                        { address = "100.64.0.3:25"; }
                    ];

                    submission.loadBalancer.servers = [
                        { address = "100.64.0.3:587"; }
                    ];

                    smtps.loadBalancer.servers = [
                        { address = "100.64.0.3:465"; }
                    ];

                    imaps.loadBalancer.servers = [
                        { address = "100.64.0.3:993"; }
                    ];
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
                mail.loadBalancer.server = [
                    {
                        url = "http://100.64.0.3:80";
                    }
                ];
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