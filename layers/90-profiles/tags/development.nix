{ lib, ... }: {
  imports = [
    ../../50-cli-tui-programs
    ../../60-gui-programs
    ../../70-agents
  ];

  features = {
    cli.pythonTools.enable = lib.mkDefault true;
    agent = {
      antigravity.enable = lib.mkDefault true;
      opencode = {
        enable = lib.mkDefault true;
        desktop = lib.mkDefault true;
      };
    };
    gui = {
      vscode.enable = lib.mkDefault true;
      dev-tools.enable = lib.mkDefault true;
    };
  };
}
