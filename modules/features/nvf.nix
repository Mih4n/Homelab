{ inputs, ... }: {
    flake.nixosModules.nvf = { ... }:  {
        imports = [
            inputs.nvf.nixosModules.default
        ];

        # programs.nvf = {
        #     enable = true;
        #     settings.vim = {
        #         theme = {
        #             enable = true;
        #             name = "gruvbox";
        #             style = "dark";
        #         };

        #         telescope.enable = true;
        #         statusline.lualine.enable = true;
        #         autocomplete.nvim-cmp.enable = true;

        #         languages = {
        #             enableLSP = true;
        #             enableTreesitter = true;


        #             ts.enable = true;
        #             nix.enable = true;
        #             css.enable = true;
        #             csharp.enable = true;
        #         };
        #     };
        # };
    }; 
}
