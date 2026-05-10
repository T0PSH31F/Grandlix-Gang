{ lib, ... }: {
  imports = [
    ../../50-cli-tui-programs
    ../../60-gui-programs
    ../../70-agents
  ];

  layers = {
    layer-50.cli.pythonTools.enable = lib.mkDefault true;
    layer-70.agent = {
      antigravity.enable = lib.mkDefault true;
      opencode = {
        enable = lib.mkDefault true;
        desktop = lib.mkDefault true;
      };
    };
    layer-60.gui = {
      vscode.enable = lib.mkDefault true;
      dev-tools.enable = lib.mkDefault true;
      brave.enable = lib.mkDefault true;
    };
  };
}
