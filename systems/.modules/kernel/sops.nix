{
    sops.defaultSopsFile = ../../../secrets/secrets.yaml;
    sops.defaultSopsFormat = "yaml";

    sops.age.keyFile = "/etc/ssh/ssh_host_ed25519_key";

    sops.secrets."bytes" = {};
    sops.secrets."nextcloud/adminpass" = {};    
}