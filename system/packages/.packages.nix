{ pkgs, ... }: {
    environment.systemPackages = with pkgs; [
        vim
        wget
        btop
        nil
    ]; 
}