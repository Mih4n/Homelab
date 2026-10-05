{ ... }: let
    nextcloud = {
        # Не синхронизируется в Nextcloud: сервер отказывает в загрузке
        # (forbidden_filenames), клиент не пытается отправлять (sync-exclude.lst).
        # Имена сравниваются целиком и без учёта регистра, без шаблонов.
        ignore = {
            names = [
                # системный мусор
                ".DS_Store" "Thumbs.db" "desktop.ini"

                # nix / окружения
                "result" ".direnv" ".devenv"

                # js / web
                "node_modules" ".next" ".nuxt" ".svelte-kit" ".angular"
                ".parcel-cache" ".turbo" ".nyc_output" ".sass-cache" ".expo"

                # python
                "__pycache__" ".venv" "venv" ".pytest_cache" ".mypy_cache"
                ".ruff_cache" ".tox" ".eggs"

                # jvm / android
                ".gradle" ".kotlin"

                # rust / zig / haskell / dart
                "target" ".zig-cache" "zig-out" ".stack-work" "dist-newstyle"
                ".dart_tool" ".pio"

                # c / c++
                "cmake-build-debug" "cmake-build-release" ".ccls-cache" ".cache"

                # общие каталоги сборки (dotnet bin/obj и т.п.)
                "bin" "obj" "out" "build" "dist" "_build"

                # terraform
                ".terraform"
            ];
            extensions = [ ".tmp" ".swp" ".pyc" ".pyo" ".o" ];
        };
    };
in {
    flake = { inherit nextcloud; };
}
