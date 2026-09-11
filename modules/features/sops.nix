{ inputs, ... }: {
    flake.nixosModules.sops = { config, ... }: {
        imports = [
            inputs.sops.nixosModules.sops
        ];

        sops.age.sshKeyPaths = [
            "/etc/ssh/ssh_host_ed25519_key"
        ];

        sops.defaultSopsFile = ../../secrets/secrets.yaml;
        sops.defaultSopsFormat = "yaml";

        sops.secrets."bytes" = {};

        sops.secrets."headscale/vpn" = {};
        sops.secrets."headscale/bytes" = {};
        sops.secrets."headscale/polygon" = {};
        sops.secrets."headscale/nextcloud" = {};

        sops.secrets."nextcloud/adminname" = {};    
        sops.secrets."nextcloud/adminpass" = {}; 

        sops.secrets."authentik/secret-key" = {};
        sops.secrets."authentik/email-password" = {};

        sops.secrets."netbird/turn-password" = {};
        sops.secrets."netbird/turn-secret" = {};
        sops.secrets."netbird/data-store-encryption-key" = {};

        # reusable, non-expiring: create once in the Netbird dashboard, reused by every client host
        sops.secrets."netbird/setup-key" = {};

        sops.templates."authentik.env".content = ''
            AUTHENTIK_SECRET_KEY=${config.sops.placeholder."authentik/secret-key"}
            AUTHENTIK_EMAIL__PASSWORD=${config.sops.placeholder."authentik/email-password"}
        '';
    };
}