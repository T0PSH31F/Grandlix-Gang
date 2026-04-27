{
  config,
  lib,
  ...
}:
let
  cfg = config.features.cli;
in
{
  home = lib.mkIf (cfg.enable && cfg.yazelixIntegration.enable) {
    programs.helix.settings.keys.normal.space.e = ":sh yazi";
    programs.zsh.initContent = lib.mkIf cfg.shells.zsh.enable ''
      yazelix() { if command -v zellij &> /dev/null; then zellij --layout compact; else echo "Zellij not available, starting helix directly"; hx "$@"; fi; }
    '';
    programs.bash.initExtra = lib.mkIf cfg.shells.bash.enable ''
      yazelix() { if command -v zellij &> /dev/null; then zellij --layout compact; else echo "Zellij not available, starting helix directly"; hx "$@"; fi; }
    '';
  };
}
