# flake-parts/features/home/cli/multiplexers/zellij.nix
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.cli-environment;
in
{
  config = lib.mkIf (cfg.enable && cfg.yazelixIntegration.enable) {
    programs.zellij = {
      enable = true;
      enableZshIntegration = false;

      settings = {
        theme = lib.mkIf cfg.theming.enable "matugen";
        pane_frames = true;
        default_layout = "compact";
        simplified_ui = true;

        keybinds = {
          normal = {
            "bind \"Ctrl q\"" = {
              Quit = { };
            };
          };
          pane = {
            "bind \"h\"" = {
              MoveFocus = "Left";
            };
            "bind \"j\"" = {
              MoveFocus = "Down";
            };
            "bind \"k\"" = {
              MoveFocus = "Up";
            };
            "bind \"l\"" = {
              MoveFocus = "Right";
            };
          };
        };
      };
    };
  };
}
