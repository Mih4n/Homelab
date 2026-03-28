{ inputs, ... }: {
    flake.homeModules.vscodeServer = { ... }: {
        imports = [
            inputs.vscode-server.homeModules.default
        ];

        services.vscode-server = {
            enable = true;
        };
    };
}