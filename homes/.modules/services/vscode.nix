{ config, lib, inputs, ... }: {
    imports = [
        inputs.vscode-server.homeModules.default
    ];

    options.bytes.home.vscode.enable = lib.mkEnableOption "vscode";

    config = lib.mkIf config.bytes.home.vscode.enable {
        services.vscode-server = {
            enable = true;
        };
    };
}