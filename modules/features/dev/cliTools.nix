{ ... }: {
    flake.nixosModules.cliTools = { pkgs, ... }: {
        environment.systemPackages = with pkgs; [
            # --- Documents (Typst) ---
            typst
            typship
            typstyle
            pandoc

            # --- PDF & OCR ---
            # tesseract ships every language, rus and eng included.
            poppler-utils
            ocrmypdf
            tesseract
            qpdf
            ghostscript
            imagemagick

            # --- Office formats ---
            markitdown

            # --- Diagrams ---
            graphviz
            d2
            mermaid-cli
            plantuml

            # --- Data & charts ---
            (python314.withPackages (ps: with ps; [
                numpy
                pandas
                matplotlib
                openpyxl
                python-docx
            ]))
            jq
            yq-go
            csvkit

            # --- Search & spelling ---
            ripgrep
            fd
            harper
            languagetool
            (hunspell.withDicts (d: with d; [ ru_RU en_US ]))
        ];
    };
}
