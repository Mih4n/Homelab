{ self, ... }: let
    s = self.settings;
in {
    flake.nixosModules.localAi = { lib, config, ... }: let
        cfg = config.bytes.localAi;
    in {
        imports = [
            self.nixosModules.localAiServer
            self.nixosModules.localAiSearx
            self.nixosModules.localAiOpencode
        ];

        options.bytes.localAi = {
            server = lib.mkEnableOption "the llama.cpp and SearXNG servers on this host";

            # Clients reach the servers through the tailnet.
            host = lib.mkOption {
                type = lib.types.str;
                default = if cfg.server then "127.0.0.1" else s.hosts.desktop;
            };

            port = lib.mkOption {
                type = lib.types.port;
                default = s.ports.llama;
            };

            searxPort = lib.mkOption {
                type = lib.types.port;
                default = s.ports.searx;
            };

            model = {
                id = lib.mkOption {
                    type = lib.types.str;
                    default = "qwen3.8-27b";
                    description = "Model id in the API and in opencode.";
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
