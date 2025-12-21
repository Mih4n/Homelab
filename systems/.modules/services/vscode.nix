{ config, lib, inputs, ... }: {
    imports = [
        inputs.vscode-server.nixosModules.default
    ];

    options.bytes.vscode.enable = lib.mkEnableOption "vscode";

    config = lib.mkIf config.bytes.vscode.enable {
        services.vscode-server = {
            enable = true;
        };
    };
}