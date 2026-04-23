{
  config,
  pkgs,
  lib,
  osConfig,
  inputs,
  ...
}:
let
  cfg = config.features.home.agent.antigravity;
  clanTags = osConfig.machine.tags or [ ];
in
{
  options.features.home.agent.antigravity = {
    enable = lib.mkEnableOption "Antigravity agentic IDE";
  };

  config = lib.mkIf (cfg.enable || builtins.elem "dev" clanTags) {
    home.packages = [
      inputs.antigravity.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
