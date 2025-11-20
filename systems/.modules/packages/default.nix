{ pkgs, ... }: {
    environment.systemPackages = with pkgs; [
        vim
        wget
        btop
        nil
        nixd
        sops
        age
    ]; 
}