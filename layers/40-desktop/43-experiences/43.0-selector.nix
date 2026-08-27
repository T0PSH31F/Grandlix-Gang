{
  config,
  lib,
  osConfig ? config,
  ...
}:
let
  hasDesktopTag = builtins.elem "desktop" (osConfig.machine.tags or [ ]);
  hasServerTag = builtins.elem "server" (osConfig.machine.tags or [ ]);
  exp = config.layers.desktop.experience;
in
{
  options.layers.desktop = {
    experience = lib.mkOption {
      type = lib.types.enum [
        "none"
        "minimal-hyprland"
        "noctalia-hyprland"
        "end4-hyprland"
      ];
      default = if hasDesktopTag then "noctalia-hyprland" else "none";
      description = "Selected desktop user experience suite";
    };

    compositor = lib.mkOption {
      type = lib.types.enum [
        "none"
        "hyprland"
        "niri"
      ];
      readOnly = true;
      default =
        if exp == "noctalia-hyprland" || exp == "end4-hyprland" || exp == "minimal-hyprland" then
          "hyprland"
        else
          "none";
      description = "Compositor engine derived from selected experience";
    };
  };

  config = {
    assertions = [
      {
        assertion = !(hasServerTag && !hasDesktopTag && exp != "none");
        message = "Server-tagged machines must set layers.desktop.experience = \"none\".";
      }
    ];
  };
}
