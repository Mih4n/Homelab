{ ... }: {
    flake.nixosModules.userMih4n = { ... }: {
        users.users.mih4n = {
            isNormalUser = true;
            description = "Mikhail";
            hashedPassword = "$6$INGxsfVqSAB.Il9c$8jOKz5AaQeCrfD8ivJj4Z4bSJFxPUnip1ibeTs07KHNLpkuFvl8pF45s8AZKt970I8pvFSSiGXKLnb5ZVW/3U1";
            extraGroups = [ "networkmanager" "wheel" "docker" ];
            openssh.authorizedKeys.keys = [
                "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIDXIGLrBWkgdmTPpM1BKieVANmpUiYu1zonWsYg73uS+AAAACXNzaDpuaXhvcw== main-usbc@ssh"
                "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIN2qiyNdRvCg162X494K+CWl4iBqLYN+ivtojBlAWccBAAAACXNzaDpuaXhvcw== main-usba@ssh"
                "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKG2HopF+e5dNqiwacnU8SCt1wSgCSLn0DEK4oDyqN2R bytekeeper@bytes"
            ];
        };
    };
}
