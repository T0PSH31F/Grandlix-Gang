{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (import ../../../layers/80-lib/81-helpers/mkDendriticModule.nix { inherit lib; }) mkDendriticModule;
in
{
  imports = [
    (mkDendriticModule "zathura" ./zathura.nix)
  ];

  options.layers.layer-60.gui.documents = {
    enable = lib.mkEnableOption "Documents & Publishing tools";

    office = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable LibreOffice suite";
      };
    };

    publishing = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable publishing tools (Pandoc, LaTeX, Scribus, Sigil)";
      };
    };

    notes = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable note-taking tools (Obsidian)";
      };
    };
  };

  home = lib.mkIf config.layers.layer-60.gui.documents.enable {
    home.packages = lib.flatten [
      (lib.optional config.layers.layer-60.gui.documents.office.enable pkgs.libreoffice-fresh)
      (lib.optionals config.layers.layer-60.gui.documents.publishing.enable [
        pkgs.pandoc
        pkgs.texliveFull
        pkgs.scribus
        pkgs.sigil
      ])
      (lib.optional config.layers.layer-60.gui.documents.notes.enable pkgs.obsidian)
      pkgs.hicolor-icon-theme
    ];
  };
}
