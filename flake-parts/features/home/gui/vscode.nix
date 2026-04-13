{
  pkgs,
  lib,
  osConfig,
  ...
}:
let
  clanTags = osConfig.machine.tags or [ ];
in
{
  config = lib.mkIf (builtins.elem "dev" clanTags) {
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
