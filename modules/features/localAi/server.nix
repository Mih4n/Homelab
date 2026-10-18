{ ... }: {
    flake.nixosModules.localAiServer = { lib, config, options, pkgs, ... }: let
        cfg = config.bytes.localAi;
        model = cfg.model;
    in lib.mkIf cfg.server (lib.mkMerge [ {
        services.llama-cpp = {
            enable = true;
            package = pkgs.llama-cpp.override { vulkanSupport = true; };

            settings = {
                # Not opened in the firewall: only tailscale0 is trusted, so
                # the laptop gets in and the LAN does not.
                host = "0.0.0.0";
                port = cfg.port;

                hf-repo = model.hfRepo;
                hf-file = model.hfFile;
                mmproj-url = "https://huggingface.co/${model.hfRepo}/resolve/main/${model.mmproj}";
                alias = model.id;

                n-gpu-layers = 999;
                ctx-size = model.context;
                # One slot gets the whole context instead of a share of it.
                parallel = 1;
                flash-attn = "on";
                cache-type-k = "q4_0";
                cache-type-v = "q4_0";
                jinja = true;

                # The vision encoder runs on the CPU, its 0.9GB of VRAM goes
                # to the context instead.
                no-mmproj-offload = true;

                spec-type = "draft-mtp";

                # Recommended sampling for Qwen3 in thinking mode.
                temp = 0.6;
                top-p = 0.95;
                top-k = 20;
                min-p = 0;

                # Frees VRAM for games when nothing is asked for 10 minutes.
                sleep-idle-seconds = 600;
            };
        };

        # DynamicUser has no home, mesa would try `//.cache` and recompile
        # the Vulkan shaders on every start.
        systemd.services.llama-cpp.environment.MESA_SHADER_CACHE_DIR = "/var/cache/llama-cpp/mesa";
    } (lib.optionalAttrs (options ? bytes.impermanence) {
        # Root is tmpfs and the model takes ~13GB, it has to live on /persist.
        # DynamicUser keeps its cache under /var/cache/private, which must stay 0700.
        systemd.tmpfiles.rules = [ "d /var/cache/private 0700 root root -" ];
        bytes.impermanence.directories = [ "/var/cache/private/llama-cpp" ];
    }) ]);
}
