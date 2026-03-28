{ pkgs, ... }: {
    flake.homeConfigurations.mih4n = {
		home = {
			username = "mih4n";
			homeDirectory = "/home/mih4n";
			stateVersion = "25.11";
		}; 

		programs.fish = {
			enable = true;

			shellInit = ''
				set -x EDITOR code
			'';

			interactiveShellInit = ''
				fish_vi_key_bindings
			'';

			shellAliases = {
				lf = "lfcd";
				os = "nh os";
				home = "nh home";
			};
		};

		programs.oh-my-posh = {
			enable = true;
			enableFishIntegration = true;
			useTheme = "gruvbox";
		};

		services.nextcloud-client = {                                             
			enable = true;
			startInBackground = true;
		};

		home.packages = [ pkgs.nextcloud-client ];
	};
}