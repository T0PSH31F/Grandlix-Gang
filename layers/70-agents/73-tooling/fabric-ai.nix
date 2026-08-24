# 🧠 Fabric AI Framework
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.layers.layer-70.agent.fabric-ai;
in
{
  options.layers.layer-70.agent.fabric-ai = {
    enable = lib.mkEnableOption "Fabric AI framework";
  };

  nixos = lib.mkIf cfg.enable {
    environment.systemPackages = lib.optional (pkgs ? fabric-ai) pkgs.fabric-ai;
  };
}
