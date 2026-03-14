{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [ inputs.yazelix.homeManagerModules.default ];

  options.features.home.cli.yazelix.enable = lib.mkEnableOption "Yazelix terminal environment";

  config = lib.mkIf config.features.home.cli.yazelix.enable {
    # Requires Nushell as a dependency but defaults to your favorite Zsh
    home.packages = [
      pkgs.nushell
      pkgs.zsh
    ];

    programs.yazelix = {
      enable = true;
      default_shell = "zsh";
      recommended_deps = true;
    };
  };
}
