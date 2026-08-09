{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.layers.layer-70.agent.codegraph = {
    enable = lib.mkEnableOption "codegraph — semantic code intelligence for AI coding agents";
  };

  config = lib.mkIf config.layers.layer-70.agent.codegraph.enable {
    environment.systemPackages = [
      pkgs.codegraph
      pkgs.lazyskills
    ];
  };
}
