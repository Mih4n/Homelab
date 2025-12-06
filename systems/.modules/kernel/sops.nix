{
    sops.defaultSopsFile = ../../../secrets/secrets.yaml;
    sops.defaultSopsFormat = "yaml";

    sops.age.keyFile = "/home/bytekeeper/.config/sops/age/keys.txt";

    sops.secrets."bytes" = {};
    sops.secrets."nextcloud/adminpass" = {};    
}