# flake-parts/features/home/gui/antigravity.nix
{
  config,
  pkgs,
  lib,
  osConfig,
  inputs,
  ...
}:
let
  clanTags = osConfig.machine.tags or [ ];
in
{
  options.home-config.antigravity.enable = lib.mkEnableOption "Antigravity agentic IDE";

  config = lib.mkIf (config.home-config.antigravity.enable || builtins.elem "dev" clanTags) {
    home.packages = [
      inputs.antigravity.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
