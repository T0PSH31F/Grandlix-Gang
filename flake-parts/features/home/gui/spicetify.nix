{
  pkgs,
  lib,
  inputs,
  osConfig,
  ...
}:
let
  clanTags = osConfig.machine.tags or [ ];
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in
{
  imports = [ inputs.spicetify-nix.homeManagerModules.default ];

  config = lib.mkIf (builtins.elem "desktop" clanTags) {
    programs.spicetify = {
      enable = true;
      theme = spicePkgs.themes.comfy;
      # colorScheme = "mocha"; # Comfy usually has specific schemes or defaults

      enabledExtensions = with spicePkgs.extensions; [
        adblock
        shuffle
      ];
    };
  };
}
