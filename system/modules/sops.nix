{
    sops.defaultSopsFile = ./secrets/secrets.yml;
    sops.defaultSopsFormat = "yaml";

    sops.age.keyFile = "/home/bytekeeper/.config/sops/age/keys.txt";
}