{
  config,
  pkgs,
  lib,
  osConfig ? config,
  inputs,
  ...
}:
let
  clanTags = osConfig.machine.tags or [ ];
in
{
#   options.layers.layer-70.agent.antigravity = {
    enable = lib.mkEnableOption "Antigravity agentic IDE" // {
      default = builtins.elem "dev" clanTags;
    };
  };

#   home = lib.mkIf config.layers.layer-70.agent.antigravity.enable {
    home.packages = [
#       inputs.antigravity.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
