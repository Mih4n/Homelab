{ self, inputs, ... }: {
    flake.homeConfigurations.bytekeeper = inputs.homeManager.lib.homeManagerConfiguration {
		pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;

        modules = [
            self.homeModules.userBytekeeper
        ];
    };

    flake.homeModules.userBytekeeper = { ... }: {
        imports = [
            self.homeModules.shell
            self.homeModules.vscodeServer
            self.homeModules.zeditorServer
        ];

        home = {
            username = "bytekeeper";
            stateVersion = "25.05";
            homeDirectory = "/home/bytekeeper";
        };
    };
}
