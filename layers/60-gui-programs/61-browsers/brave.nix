{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.layers.layer-60.gui.brave = {
    enable = lib.mkEnableOption "Brave Browser";
  };

  home = lib.mkIf config.layers.layer-60.gui.brave.enable {
    programs.chromium = {
      enable = true;
      package = pkgs.brave;
      extensions =
        let
          ids = [
            "ficfmibkjjnpogdcfhfokmihanoldbfe" # File Icons for GitHub and GitLab
          ];
        in
        builtins.map (id: { inherit id; }) ids;
    };
  };
}
