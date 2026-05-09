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
  options.layers.layer-60.gui.thunderbird = {
    enable = lib.mkEnableOption "Thunderbird Mail Client" // {
      default = builtins.elem "desktop" clanTags || builtins.elem "workstation" clanTags;
    };
  };

  home = lib.mkIf config.layers.layer-60.gui.thunderbird.enable {
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
