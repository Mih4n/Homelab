{ ... }: {
  flake.homeModules.zeditor = { ... }: {
    programs.zed-editor = {
      enable = true;
      installRemoteServer = true;
    };
  };
}
