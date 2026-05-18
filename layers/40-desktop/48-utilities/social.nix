{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.layers.layer-40.desktop.social = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable social/communication apps";
    };
  };

  home = lib.mkIf config.layers.layer-40.desktop.social.enable {
    home.packages = with pkgs; [
      # beeper
      # beeper-bridge-manager
      signal-desktop
      signal-cli
      ayugram-desktop
      tdl
      element-desktop
      cinny
      vesktop
      equibop
      caprine
      ferdium
    ];
  };
}
