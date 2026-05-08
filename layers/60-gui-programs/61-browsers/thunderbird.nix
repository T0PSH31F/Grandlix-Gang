{
  lib,
  config,
  osConfig ? config,
  ...
}:
let
  clanTags = osConfig.machine.tags or [ ];
in
{
  options.features.gui.thunderbird = {
    enable = lib.mkEnableOption "Thunderbird Mail Client" // {
      default = builtins.elem "desktop" clanTags || builtins.elem "workstation" clanTags;
    };
  };

  home = lib.mkIf config.features.gui.thunderbird.enable {
    programs.thunderbird = {
      enable = true;
      profiles = {
        default = {
          isDefault = true;
        };
      };
    };
  };
}
