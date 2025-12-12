{ config, lib, ... }: {
    options.bytes.vscode.enable = lib.mkEnableOption "vscode";

    config = {
        services.vscode-server = {
            enable = config.bytes.vscode.enable;
        };
    };
}