{ self, inputs, ... }: let
    s = self.settings;
in {
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
			username = s.users.main;
			homeDirectory = "/home/${s.users.main}";
			stateVersion = "25.11";
		};
	};
}
