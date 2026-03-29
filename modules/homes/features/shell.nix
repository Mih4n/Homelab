{ ... }: {
    flake.homeModules.shell = { ... }: {
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
    };
}