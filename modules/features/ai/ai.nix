{ self, ... }: let
    s = self.settings;
in {
    flake.nixosModules.ai = { lib, config, ... }: let
        cfg = config.bytes.ai;
    in {
        imports = [
            self.nixosModules.aiServer
            self.nixosModules.aiOpencode
        ];

        # Pulled in by one of the MCP servers used by OpenCode; it is marked
        # broken in nixpkgs but works for our use.
        config.nixpkgs.config.problems.handlers."fastmcp-slim".broken = "warn";

        options.bytes.ai = {
            server = lib.mkEnableOption "the local llama.cpp server on this host";

            provider = lib.mkOption {
                type = lib.types.enum [ "opencode-go" "llama-cpp" ];
                default = "opencode-go";
                description = "Default provider for OpenCode.";
            };

            models = {
                thinking = lib.mkOption {
                    type = lib.types.str;
                    default = "opencode-go/deepseek-v4-pro";
                    description = "Model for planning and review.";
                };

                execution = lib.mkOption {
                    type = lib.types.str;
                    default = "opencode-go/deepseek-v4.1-flash";
                    description = "Cheaper model for subagents and routine work.";
                };
            };

            # Clients reach a local server through the tailnet.
            host = lib.mkOption {
                type = lib.types.str;
                default = if cfg.server then "127.0.0.1" else s.hosts.desktop;
            };

            port = lib.mkOption {
                type = lib.types.port;
                default = s.ports.llama;
            };

            # SearXNG is a separate service on the n8n host.
            searxUrl = lib.mkOption {
                type = lib.types.str;
                default = "http://${s.hosts.n8n}:${toString s.ports.searx}";
            };

            model = {
                id = lib.mkOption {
                    type = lib.types.str;
                    default = "qwen3.8-27b";
                    description = "Model id in the local API and in opencode.";
                };

                name = lib.mkOption {
                    type = lib.types.str;
                    default = "Qwen3.8 27B";
                };

                hfRepo = lib.mkOption {
                    type = lib.types.str;
                    default = "ISTA-DASLab/Qwen3.8-27B-GSQ-RCO-GGUF";
                };

                # The -mtp build carries the Multi-Token Prediction head for
                # speculative decoding, otherwise it is the same IQ3_S.
                hfFile = lib.mkOption {
                    type = lib.types.str;
                    default = "Qwen3.8-27B-GSQ-RCO-IQ3_S-mtp.gguf";
                };

                mmproj = lib.mkOption {
                    type = lib.types.str;
                    default = "mmproj-Qwen3.8-27B-BF16.gguf";
                };

                # 16 of 64 layers keep a KV cache, ~35KB per token at q8_0:
                # 64k is ~2.2GB next to the 12.1GB of weights on a 16GB card.
                context = lib.mkOption {
                    type = lib.types.int;
                    default = 65536;
                };

                output = lib.mkOption {
                    type = lib.types.int;
                    default = 16384;
                };
            };
        };
    };
}
