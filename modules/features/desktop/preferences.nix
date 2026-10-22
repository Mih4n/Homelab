{ ... }: {
    flake.nixosModules.preferences = { lib, ... }: let
        associations = {
            "zen.desktop" = [
                "text/html"
                "application/xhtml+xml"
                "x-scheme-handler/http"
                "x-scheme-handler/https"
                "x-scheme-handler/about"
                "x-scheme-handler/unknown"
            ];

            "dev.zed.Zed.desktop" = [
                "text/plain"
                "text/markdown"
                "text/x-csrc"
                "text/x-chdr"
                "text/x-c++src"
                "text/x-python"
                "text/x-shellscript"
                "text/x-nix"
                "application/json"
                "application/toml"
                "application/x-yaml"
                "application/xml"
            ];

            "org.gnome.Nautilus.desktop" = [
                "inode/directory"
            ];

            "org.kde.okular.desktop" = [
                "application/pdf"
                "application/epub+zip"
                "image/vnd.djvu"
            ];

            "org.gnome.Loupe.desktop" = [
                "image/png"
                "image/jpeg"
                "image/gif"
                "image/webp"
                "image/bmp"
                "image/tiff"
                "image/avif"
                "image/heic"
                "image/svg+xml"
            ];

            "mpv.desktop" = [
                "video/mp4"
                "video/webm"
                "video/x-matroska"
                "video/quicktime"
                "video/x-msvideo"
                "video/mpeg"
            ];

            "org.kde.elisa.desktop" = [
                "audio/mpeg"
                "audio/flac"
                "audio/ogg"
                "audio/opus"
                "audio/wav"
                "audio/x-wav"
                "audio/aac"
                "audio/mp4"
            ];

            "org.kde.ark.desktop" = [
                "application/zip"
                "application/x-tar"
                "application/x-compressed-tar"
                "application/x-bzip-compressed-tar"
                "application/x-xz-compressed-tar"
                "application/zstd"
                "application/x-7z-compressed"
                "application/vnd.rar"
            ];

            "onlyoffice-desktopeditors.desktop" = [
                "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
                "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
                "application/vnd.openxmlformats-officedocument.presentationml.presentation"
                "application/msword"
                "application/vnd.ms-excel"
                "application/vnd.ms-powerpoint"
            ];

            "writer.desktop" = [ "application/vnd.oasis.opendocument.text" ];
            "calc.desktop" = [ "application/vnd.oasis.opendocument.spreadsheet" ];
            "impress.desktop" = [ "application/vnd.oasis.opendocument.presentation" ];

            "org.telegram.desktop.desktop" = [ "x-scheme-handler/tg" ];
            "thunderbird.desktop" = [ "x-scheme-handler/mailto" ];
        };
    in {
        xdg.mime = {
            enable = true;
            defaultApplications = lib.zipAttrs (lib.concatLists (lib.mapAttrsToList
                (app: mimes: map (mime: { ${mime} = app; }) mimes)
                associations));
        };
    };
}
