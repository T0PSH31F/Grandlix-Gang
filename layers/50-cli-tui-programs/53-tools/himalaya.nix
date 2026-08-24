{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.layers.layer-50.cli;
in
{
  # NOTE: the himalaya config.toml (xdg.configFile) lives in
  # layers/10-system/13-users/t0psh31f.nix, not here. This "home" block is
  # pre-evaluated by mkDendriticModule using the outer NixOS config, which
  # has no `sops.secrets` of its own — those only exist in the real
  # home-manager submodule scope where the secrets are declared.
  home =
    { ... }:
    lib.mkIf cfg.enable {
      home.packages = with pkgs; [
        himalaya
      ];
    };
}
