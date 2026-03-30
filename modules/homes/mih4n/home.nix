{ self, inputs, ... }: {
    flake.homeConfigurations.mih4n = inputs.homeManager.lib.homeManagerConfiguration {
		pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;

		modules = [
			self.homeModules.userMih4n
		];
	};

	flake.homeModules.userMih4n = { ... }: {
		imports = [
			self.homeModules.shell
			self.homeModules.nextcloudClient
		];

		home = {
			username = "mih4n";
			homeDirectory = "/home/mih4n";
			stateVersion = "25.11";
		}; 	
	};
}