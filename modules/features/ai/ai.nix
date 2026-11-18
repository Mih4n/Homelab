{ self, ... }: let
    s = self.settings;
in {
    flake.nixosModules.ai = { lib, config, ... }: {
        imports = [
            self.nixosModules.searx
            self.nixosModules.aiOpencode
        ];

        config.nixpkgs.config.problems.handlers."fastmcp-slim".broken = "warn";

        options.bytes.ai = {
            searxUrl = lib.mkOption {
                type = lib.types.str;
                default = "http://localhost:${toString s.ports.searx}";
            };

            rag = {
                directory = lib.mkOption {
                    type = lib.types.str;
                    default = "/home/${s.users.main}/Nextcloud";
                    description = "Document folder indexed into Qdrant.";
                };

                qdrantUrl = lib.mkOption {
                    type = lib.types.str;
                    default = "http://localhost:6333";
                    description = "URL of the Qdrant instance.";
                };

                collection = lib.mkOption {
                    type = lib.types.str;
                    default = "documents";
                    description = "Qdrant collection for the document archive.";
                };

                embeddingModel = lib.mkOption {
                    type = lib.types.str;
                    default = "BAAI/bge-m3";
                    description = "Embedding model for Qdrant.";
                };
            };
        };
    };
}
