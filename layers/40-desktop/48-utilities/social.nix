{ pkgs, lib, config, ... }: {
  options.features.desktop.social = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable social/communication apps";
    };
  };

  home = lib.mkIf config.features.desktop.social.enable {
    home.packages = with pkgs; [
      beeper
      beeper-bridge-manager
      signal-desktop
      signal-cli
      ayugram-desktop
      tdl
      element-desktop
      vesktop
      equibop
      caprine
    ];
  };
}
