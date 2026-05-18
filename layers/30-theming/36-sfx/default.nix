{
  config,
  lib,
  osConfig ? config,
  ...
}:
let
  clanTags = osConfig.machine.tags or [ ];
in
{
  options.layers.layer-30.theming.sfx = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = builtins.elem "desktop" clanTags;
      description = "Enable UI sound effects daemon";
    };

    sounds = {
      switchFocus = lib.mkOption {
        type = lib.types.str;
        default = "switch-focus.wav";
        description = "Sound to play when focusing a window";
      };
      moveWindow = lib.mkOption {
        type = lib.types.str;
        default = "move-window.wav";
        description = "Sound to play when moving a window";
      };
      openWindow = lib.mkOption {
        type = lib.types.str;
        default = "open-window.wav";
        description = "Sound to play when opening a window";
      };
      closeWindow = lib.mkOption {
        type = lib.types.str;
        default = "close-window.wav";
        description = "Sound to play when closing a window";
      };
    };
  };
}
