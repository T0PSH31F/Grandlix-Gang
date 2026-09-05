{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.layers.layer-70.agent.supergraph = {
    enable = lib.mkEnableOption "supergraph — monorepo intelligence for AI coding agents";
  };

  config = lib.mkIf config.layers.layer-70.agent.supergraph.enable {
    environment.systemPackages = [ pkgs.supergraph ];
  };
}
