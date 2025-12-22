{ config, lib, inputs, ... }: {
    imports = [
        inputs.mailserver.nixosModule
    ];

    options.bytes.mailserver = {
        enable = lib.mkEnableOption "mailserver";
        domain = lib.mkOption {
            type = lib.types.str;
            default = "mih4n.xyz";
        };
        subdomain = lib.mkOption {
            type = lib.types.str;
            default = "mail";
        };
        emails = lib.mkOption {
            type = lib.types.listOf (lib.types.submodule {
                options = {
                    username = lib.mkOption {
                        type = lib.types.str;
                        description = "Email username (before @)";
                    };
                    aliases = lib.mkOption {
                        type = lib.types.listOf lib.types.str;
                        default = [];
                        description = "Aliases to email address (before @)";
                    };
                    hashedPasswordFile = lib.mkOption {
                        type = lib.types.nullOr lib.types.path;
                        description = "Path to hashed password file";
                    };
                };
            });
            default = [];
        };
    };

    config = let
        cfg = config.bytes.mailserver;
        fqdn = "${cfg.subdomain}.${cfg.domain}";
    in lib.mkIf cfg.enable {
        mailserver = {
            enable = true;
            stateVersion = 3;
            fqdn = fqdn;
            domains = [ cfg.domain ];

            loginAccounts = lib.listToAttrs (
                map (email: 
                    {
                        name = "${email.username}@${cfg.domain}";
                        value = {
                            hashedPasswordFile = email.hashedPasswordFile;
                            aliases = map (a: "${a}@${cfg.domain}") email.aliases;
                        };
                    }
                )
                cfg.emails
            );

            x509.useACMEHost = fqdn;
        };

        security.acme = {
            acceptTerms = true;
            defaults.email = "security@${cfg.domain}";
            certs.${fqdn} = {
                listenHTTP = ":8080";
            };
        };
    };
}