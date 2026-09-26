{ ... }: {
  flake.homeModules.zeditorServer = { ... }: {
    programs.zed-editor = {
      enable = true;
      installRemoteServer = true;
    };
  };
}
