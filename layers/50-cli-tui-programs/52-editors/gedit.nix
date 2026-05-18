{
  config,
  lib,
  pkgs,
  osConfig ? config,
  ...
}:
let
  cfg = config.layers.layer-50.cli.gedit;
in
{
  options.layers.layer-50.cli.gedit = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = builtins.elem "desktop" (osConfig.machine.tags or [ ]);
      description = "Enable Gedit text editor with custom dconf settings";
    };
  };

  home = lib.mkIf cfg.enable {
    home.packages = [ pkgs.gedit ];

    # Gedit preferences via dconf
    dconf.settings = {
      "org/gnome/gedit/preferences/editor" = {
        scheme = "noctalia";
        use-default-font = false;
        editor-font = lib.mkDefault "JetBrainsMono Nerd Font 14";
        display-line-numbers = true;
        highlight-current-line = true;
        bracket-matching = true;
        auto-indent = true;
        tabs-size = lib.mkDefault 4;
        insert-spaces = true;
      };
    };
  };
}
