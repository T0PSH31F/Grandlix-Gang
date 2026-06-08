{
  config,
  pkgs,
  lib,
  osConfig ? config,
  ...
}:
let
  clanTags = osConfig.machine.tags or [ ];
  isDesktop = builtins.elem "desktop" clanTags;
in
{
  config = lib.mkIf isDesktop {
    home.packages = with pkgs; [
      nwg-displays
      wlr-randr
    ];

    # nwg-displays generates ~/.config/hypr/monitors.conf by default
    # but we handle monitors in monitors.nix.
    # We should probably let nwg-displays manage its own file and include it.
  };
}
