{
    sops.defaultSopsFile = ../../../secrets/secrets.yaml;
    sops.defaultSopsFormat = "yaml";

    sops.secrets."bytes" = {};
    sops.secrets."nextcloud/adminname" = {};    
    sops.secrets."nextcloud/adminpass" = {};    
}