{
  config,
  lib,
  ...
}:
{
  options.layers.layer-60.gui.zathura = {
    enable = lib.mkEnableOption "Zathura PDF viewer";
  };

  home = lib.mkIf config.layers.layer-60.gui.zathura.enable {
    programs.zathura = {
      enable = true;
      options = {
        selection-clipboard = "clipboard";
      };
      extraConfig = "include noctaliarc";
    };

  };
}
