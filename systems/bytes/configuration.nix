{ config, ... }: {
    imports = [ 
        ./modules
        ../.modules
        
        ./hardware-configuration.nix
    ];

    bytes = let 
        secrets = config.sops.secrets;
    in {
        hostName = "bytes";

        mailserver = {
            enable = true;
            emails = [
                {
                    username = "auth";
                    hashedPasswordFile = secrets."mail/auth-hash".path;
                }
                {
                    username = "selfish";
                    hashedPasswordFile = secrets."mail/selfish-hash".path;
                }
                {
                    username = "no-reply";
                    hashedPasswordFile = secrets."mail/no-reply-hash".path;
                }
            ];
        };

        vscode.enable = true;
        tailscale = {
            enable = true;
            isExiteNode = true;
            subnetRoutes = [
                "192.168.192.0/24"
            ];
            authKeyFile = secrets."headscale/bytes".path;
        };
        
        users.byteshaker.enable = false;
        local-networking.enable = false;
    };

    system.stateVersion = "25.05";
}
