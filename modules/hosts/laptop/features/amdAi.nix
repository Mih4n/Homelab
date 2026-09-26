{ inputs, ... }: {
    flake.nixosModules.amdAi = { ... }: {
        imports = [ inputs.amd-ai.nixosModules.default ];

        hardware.amd-npu = {
            enable = true;
            enableNPU = true;
            enableVulkan = true;
            enableLemonade = true;
            lemonade = {
                user = "mih4n";
                models = [
                    "user.Qwen2.5-Coder-1.5B-Base"
                    "user.Qwen2.5-Coder-3B-Instruct"
                ];
                settings = {
                  max_loaded_models = 2;
                };
            };
        };

        users.users.mih4n = {
            extraGroups = [ "video" "render" ];
        };
    };
}
