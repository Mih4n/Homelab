{ ... }: {
    flake.nixosModules.userBytekeeper = { ... }: {
        users.users.bytekeeper = {
            isNormalUser = true;
            description = "bytekeeper";
            extraGroups = [ "networkmanager" "wheel" ];
            hashedPassword = "$6$INGxsfVqSAB.Il9c$8jOKz5AaQeCrfD8ivJj4Z4bSJFxPUnip1ibeTs07KHNLpkuFvl8pF45s8AZKt970I8pvFSSiGXKLnb5ZVW/3U1";
            openssh.authorizedKeys.keys = let
                book = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEhGEuX/1xyax5qBKkpqj825TVcqVijbMbOHC5mVCA4I";
                desktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM1RX8c2dsj1+gs/utfV2A5RKolvWia+PZbA9FT7Q4Eo mih4n@desktop";

                allKeys = [
                    book
                    desktop
                    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIDXIGLrBWkgdmTPpM1BKieVANmpUiYu1zonWsYg73uS+AAAACXNzaDpuaXhvcw== main-usbc@ssh"
                    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIN2qiyNdRvCg162X494K+CWl4iBqLYN+ivtojBlAWccBAAAACXNzaDpuaXhvcw== main-usba@ssh"
                ];
            in allKeys;
        };
    };
}
