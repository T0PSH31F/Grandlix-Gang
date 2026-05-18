{ config, lib, pkgs, ... }:
let cfg = config.layers.layer-60.gui.activities."3d-modeling";
in {
  options.layers.layer-60.gui.activities."3d-modeling".enable = lib.mkEnableOption "3D Modeling";
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      blender
       ];
  };
}
