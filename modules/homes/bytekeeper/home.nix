{ self, ... }: {
    flake.homeConfigurations.bytekeeper = { 
        imports = [
            self.homeModules.vscodeServer
        ];

        bytes.home = {
            vscode.enable = true;
        };

        home = {
            username = "bytekeeper";
            stateVersion = "25.05";
            homeDirectory = "/home/bytekeeper";
        };
    };
}
