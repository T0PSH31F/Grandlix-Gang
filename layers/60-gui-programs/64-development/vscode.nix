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
  options.features.gui.vscode = {
    enable = lib.mkEnableOption "VS Code" // {
      default = builtins.elem "dev" clanTags;
    };
  };

  home = lib.mkIf config.features.gui.vscode.enable {
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
