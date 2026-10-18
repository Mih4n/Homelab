{ ... }: {
    flake.nixosModules.lsp = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            # --- .NET / JVM / native ---
            csharp-ls
            jdt-language-server
            rust-analyzer

            # --- Python ---
            basedpyright
            # opencode looks for pyright-langserver, Zed for basedpyright.
            pyright
            ruff

            # --- Web ---
            typescript-language-server
            vscode-langservers-extracted
            tailwindcss-language-server
            emmet-language-server
            vue-language-server
            svelte-language-server
            astro-language-server

            # --- Config, shell, data ---
            nixd
            bash-language-server
            yaml-language-server
            taplo
            dockerfile-language-server
            sqls

            # --- Documents ---
            tinymist
            marksman
            harper
        ];
    };
}
