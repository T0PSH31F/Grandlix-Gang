{
  config,
  lib,
  pkgs,
  osConfig ? config,
  ...
}:
let
  clanTags = osConfig.machine.tags or [ ];
in
{
  options.layers.layer-60.gui.vscode = {
    enable = lib.mkEnableOption "VS Code";
  };

  home = lib.mkIf config.layers.layer-60.gui.vscode.enable {
    home.packages = with pkgs; [
      bun
      nodejs
      yarn
    ];

    # VS Code with FHS compatibility
    programs.vscode = {
      enable = true;
      package = pkgs.vscode-fhs;
    };

    programs.go.enable = true;
  };
}
