{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.cli;
in
{
  home = lib.mkIf (cfg.enable && cfg.nixToolsHM.enable) {
    home.packages = with pkgs; [ nil nixd nixfmt statix deadnix nix-tree nix-search-tv nh ];
  };
}
