{
  config,
  lib,
  ...
}:
let
  cfg = config.layers.layer-50.cli;
in
{
  home = lib.mkIf (cfg.enable && cfg.shells.bash.enable) {
    programs.bash = {
      enable = true;
      enableCompletion = true;
      initExtra = ''
        if [ -n "$IN_NIX_SHELL" ]; then
          export PS1="[nix-shell] $PS1"
        fi
      '';
    };
  };
}
