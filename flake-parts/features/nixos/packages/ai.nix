# flake-parts/features/nixos/packages/ai.nix
{
  config,
  lib,
  pkgs,
  ...
}:
let
  hasTag = tag: builtins.elem tag (config.machine.tags or [ ]);
in
{

  config = lib.mkMerge [
    (lib.mkIf (hasTag "ai-server") {
      environment.systemPackages = with pkgs; [
        ollama
      ];
    })
    {
      services.hyprwhspr-rs = {
        enable = true;
      };
    }
  ];
}
