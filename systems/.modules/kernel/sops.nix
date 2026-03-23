{ inputs, ... }: {
    imports = [
        inputs.sops-nix.nixosModules.sops
    ];

    sops.defaultSopsFile = ../../../secrets/secrets.yaml;
    sops.defaultSopsFormat = "yaml";

    sops.secrets."bytes" = {};


    sops.secrets."headscale/vpn" = {};
    sops.secrets."headscale/bytes" = {};
    sops.secrets."headscale/polygon" = {};
    sops.secrets."headscale/nextcloud" = {};

    sops.secrets."nextcloud/adminname" = {};    
    sops.secrets."nextcloud/adminpass" = {};    
}