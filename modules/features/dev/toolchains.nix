{ ... }: {
    flake.nixosModules.toolchains = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            # Rust
            cargo
            rustc
            # Java
            jdk
            maven
            # .NET
            (dotnetCorePackages.combinePackages [
                dotnetCorePackages.sdk_9_0
                dotnetCorePackages.sdk_10_0
            ])
            dotnet-ef
            # Node.js
            nodejs
            # python, the interpreter with packages comes from cliTools
            uv
        ];
    };
}
