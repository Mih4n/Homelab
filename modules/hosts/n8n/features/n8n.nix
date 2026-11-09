{ self, ... }: let
    s = self.settings;
in {
    flake.nixosModules.n8nServer = { config, pkgs, ... }: let
        secrets = config.sops.secrets;
    in {
        # Root-readable file; systemd loads it as a credential before dropping
        # privileges, so DynamicUser can still read it.
        sops.secrets."n8n/encryption-key".owner = "root";

        # Secrets for the n8n code sandbox stack.
        sops.secrets."n8n/sandbox-api-key" = {};
        sops.secrets."n8n/sandbox-runner-registration-token" = {};
        sops.secrets."n8n/sandbox-runner-api-key" = {};

        services.n8n = {
            enable = true;

            environment = {
                N8N_HOST = s.domains.n8n;
                N8N_PROTOCOL = "https";
                N8N_PORT = s.ports.n8n;
                N8N_LISTEN_ADDRESS = "0.0.0.0";

                WEBHOOK_URL = "https://${s.domains.n8n}/";
                N8N_EDITOR_BASE_URL = "https://${s.domains.n8n}/";
                # Один обратный прокси (traefik на vpn) перед n8n.
                N8N_PROXY_HOPS = 1;

                N8N_ENCRYPTION_KEY_FILE = secrets."n8n/encryption-key".path;

                # AI Assistant code sandbox and web search.
                N8N_INSTANCE_AI_SANDBOX_ENABLED = "true";
                N8N_INSTANCE_AI_SANDBOX_PROVIDER = "n8n-sandbox";
                N8N_INSTANCE_AI_SEARXNG_URL = "http://127.0.0.1:${toString s.ports.searx}";
            };
        };

        # n8n Assistant не умеет добавлять кастомные заголовки, а OpenCode Go
        # требует x-opencode-session. Локальный прокси добавляет его сам.
        services.caddy = {
            enable = true;
            virtualHosts."http://127.0.0.1:8787" = {
                extraConfig = ''
                    bind 127.0.0.1
                    reverse_proxy https://opencode.ai {
                        header_up x-opencode-session "n8n-assistant"
                    }
                '';
            };
        };

        # n8n Sandbox: sandbox-api + privileged Docker-in-Docker runner.
        virtualisation.docker.enable = true;

        systemd.tmpfiles.rules = [
            "d /var/lib/n8n-sandbox 0755 root root -"
        ];

        systemd.services.n8n-sandbox = {
            description = "n8n code sandbox stack";
            wantedBy = [ "multi-user.target" ];
            after = [ "docker.service" "sops-install-secrets.service" ];
            requires = [ "docker.service" ];

            path = [ pkgs.coreutils pkgs.docker-compose ];

            serviceConfig = {
                Type = "oneshot";
                RemainAfterExit = true;
                WorkingDirectory = "/var/lib/n8n-sandbox";
            };

            script = ''
                set -eu
                export SANDBOX_API_KEYS="$(cat ${secrets."n8n/sandbox-api-key".path})"
                export SANDBOX_API_RUNNER_REGISTRATION_TOKEN="$(cat ${secrets."n8n/sandbox-runner-registration-token".path})"
                export SANDBOX_API_RUNNER_API_KEY="$(cat ${secrets."n8n/sandbox-runner-api-key".path})"
                ${pkgs.docker-compose}/bin/docker-compose \
                    -p n8n-sandbox \
                    -f ${./sandbox-compose.yml} \
                    up -d --remove-orphans
            '';
        };
    };
}
