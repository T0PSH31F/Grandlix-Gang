# Tier: 50-cli-tui-programs / 51-shells
# Module: yazelix-nova.nix
# Purpose: Yazelix Nova flake workspace integration with non-conflicting keybindings.
# Option Path: layers.layer-50.cli.yazelix-nova
# Enabling Host Tags: desktop, workstation, development
{
  config,
  lib,
  pkgs,
  inputs ? { },
  ...
}:

{
  options.layers.layer-50.cli.yazelix-nova = {
    enable = lib.mkEnableOption "Yazelix Nova shell & workspace manager";
  };

  nixos =
    let
      cfg = config.layers.layer-50.cli.yazelix-nova;
      novaPkg = inputs.nova.packages.${pkgs.stdenv.hostPlatform.system}.default or pkgs.yazi;
    in
    lib.mkIf cfg.enable {
      environment.systemPackages = [
        novaPkg
      ];
    };

  home =
    let
      cfg = config.layers.layer-50.cli.yazelix-nova;
    in
    lib.mkIf cfg.enable {
      xdg.configFile."nova/nova.toml".text = ''
        [workspace]
        keybinding = "Alt+N"
        shell = "${pkgs.zsh}/bin/zsh"
        editor = "${pkgs.neovim}/bin/nvim"
        file_manager = "${pkgs.yazi}/bin/yazi"

        [theme]
        preset = "cyberpunk"
      '';
    };
}
