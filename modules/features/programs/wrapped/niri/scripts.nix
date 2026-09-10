{ ... }: {
    # Adds a `scripts` option to the niri wrapper: every entry becomes a real
    # shell program in the store and (optionally) gets bound to a key.
    flake.wrappedModules.niriScripts = { config, lib, pkgs, ... }: {
        options.scripts = lib.mkOption {
            default = { };
            description = ''
                Shell programs built with `writeShellApplication` and bound to a key.

                `packages` are put on PATH of the script, so the body can call
                the binaries by their plain name.
            '';
            example = lib.literalExpression ''
                {
                    colorPicker = {
                        bind = "Mod+Shift+C";
                        packages = with pkgs; [ hyprpicker wl-clipboard ];
                        text = "hyprpicker | wl-copy";
                    };
                }
            '';
            type = lib.types.attrsOf (lib.types.submodule ({ name, config, ... }: {
                options = {
                    name = lib.mkOption {
                        type = lib.types.str;
                        default = name;
                        description = "Name of the resulting binary.";
                    };

                    bind = lib.mkOption {
                        type = lib.types.nullOr lib.types.str;
                        default = null;
                        example = "Mod+Shift+S";
                        description = "Key combo that runs the script, or null to only build it.";
                    };

                    props = lib.mkOption {
                        type = lib.types.attrs;
                        default = { };
                        example = { allow-when-locked = true; };
                        description = "Extra properties on the generated bind node.";
                    };

                    packages = lib.mkOption {
                        type = lib.types.listOf lib.types.package;
                        default = [ ];
                        description = "Packages available on PATH inside the script.";
                    };

                    text = lib.mkOption {
                        type = lib.types.lines;
                        default = "";
                        description = "Body of the script.";
                    };

                    package = lib.mkOption {
                        type = lib.types.package;
                        readOnly = true;
                        description = "Resulting package, built from `text`.";
                    };

                    command = lib.mkOption {
                        type = lib.types.str;
                        readOnly = true;
                        description = "Absolute path to the built script.";
                    };
                };

                config = {
                    package = pkgs.writeShellApplication {
                        inherit (config) name text;
                        runtimeInputs = config.packages;
                    };

                    command = lib.getExe config.package;
                };
            }));
        };

        config.settings.binds = lib.mapAttrs'
            (_: script: lib.nameValuePair script.bind (_: {
                inherit (script) props;
                content.spawn = script.command;
            }))
            (lib.filterAttrs (_: script: script.bind != null) config.scripts);
    };
}
