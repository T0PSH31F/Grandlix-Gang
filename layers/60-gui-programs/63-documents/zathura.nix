{
  config,
  lib,
  ...
}:
{
  options.features.gui.zathura = {
    enable = lib.mkEnableOption "Zathura PDF viewer";
  };

  home = lib.mkIf config.features.gui.zathura.enable {
    programs.zathura = {
      enable = true;
      options = {
        selection-clipboard = "clipboard";
      };
    };
  };
}
