{ ... }: let
    domain = "mih4n.xyz";
    localDomain = "bytes";

    getPublicDomain = name: "${name}.${domain}";
    getInternalDomain = name: "${name}.${localDomain}";

    sshKeys = {
        ykUsba = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIN2qiyNdRvCg162X494K+CWl4iBqLYN+ivtojBlAWccBAAAACXNzaDpuaXhvcw== main-usba@ssh";
        ykUsbc = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIDXIGLrBWkgdmTPpM1BKieVANmpUiYu1zonWsYg73uS+AAAACXNzaDpuaXhvcw== main-usbc@ssh";

        book = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEhGEuX/1xyax5qBKkpqj825TVcqVijbMbOHC5mVCA4I";
        bytes = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKG2HopF+e5dNqiwacnU8SCt1wSgCSLn0DEK4oDyqN2R bytekeeper@bytes";
        desktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM1RX8c2dsj1+gs/utfV2A5RKolvWia+PZbA9FT7Q4Eo mih4n@desktop";
    };

    settings = {
        inherit domain localDomain;

        domains = {
            root = domain;

            git = getPublicDomain "git";
            vpn = getPublicDomain "vpn";
            auth = getPublicDomain "auth";
            home = getPublicDomain "home";
            cloud = getPublicDomain "cloud";
            proxmox = getPublicDomain "proxmox";
            takeapunch = getPublicDomain "takeapunch";
        };

        hosts = {
            git = getInternalDomain "git";
            vpn = getInternalDomain "vpn";
            bytes = getInternalDomain "bytes";
            laptop = getInternalDomain "laptop";
            desktop = getInternalDomain "desktop";
            polygon = getInternalDomain "polygon";
            nextcloud = getInternalDomain "nextcloud";
        };

        net = {
            dns = "192.168.192.5";
            subnet = "192.168.192.0/24";
            gateway = "192.168.192.5";

            ips = {
                git = "192.168.192.13";
                bytes = "192.168.192.5";
                polygon = "192.168.192.12";
                nextcloud = "192.168.192.11";
                homeassistant = "192.168.192.10";
            };
        };

        users = {
            main = "mih4n";
            keeper = "bytekeeper";
            shaker = "byteshaker";
        };

        emails = {
            acme = "lmih4nl@gmail.com";
            forgejo = "selfish@${domain}";
            personal = "losevmisha0@gmail.com";
            authentik = "bytes@${domain}";
        };

        ports = {
            headscale = 3009;
            forgejoSsh = 2222;
            forgejoHttp = 3000;
        };

        sshKeys = sshKeys // {
            yubikeys = [ sshKeys.ykUsbc sshKeys.ykUsba ];
        };
    };
in {
    flake = { inherit settings; };
}
