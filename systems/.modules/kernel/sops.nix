{ inputs, ... }: {
    imports = [
        inputs.sops-nix.nixosModules.sops
    ];

    sops.defaultSopsFile = ../../../secrets/secrets.yaml;
    sops.defaultSopsFormat = "yaml";

    sops.secrets."bytes" = {};

    sops.secrets."mail/auth" = {};
    sops.secrets."mail/selfish" = {};
    sops.secrets."mail/no-reply" = {};

    sops.secrets."mail/auth-hash" = {};
    sops.secrets."mail/selfish-hash" = {};
    sops.secrets."mail/no-reply-hash" = {};

    sops.secrets."headscale/vpn" = {};
    sops.secrets."headscale/bytes" = {};
    sops.secrets."headscale/nextcloud" = {};

    sops.secrets."nextcloud/adminname" = {};    
    sops.secrets."nextcloud/adminpass" = {};    
}