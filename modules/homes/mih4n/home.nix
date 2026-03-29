{ self, ... }: {
    flake.homeConfigurations.mih4n = { ... }: {
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