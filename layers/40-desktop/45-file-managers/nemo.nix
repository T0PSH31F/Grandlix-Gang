{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.layers.layer-40.desktop.nemo = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Nemo file manager";
    };
  };

  home = lib.mkIf config.layers.layer-40.desktop.nemo.enable {
    home.packages = with pkgs; [
      nemo-with-extensions
      nemo-fileroller
      nemo-python
    ];

    dconf.settings = {
      "org/nemo/preferences" = {
        show-hidden-files = true;
        default-folder-viewer = "list-view";
      };
    };

    home.file.".config/gtk-3.0/bookmarks".text = ''
      file:///home/t0psh31f/Downloads Downloads
      file:///home/t0psh31f/Documents Documents
      file:///home/t0psh31f/GoogleDrive Google Drive
      file:///home/t0psh31f/Agents Agents
      file:///home/t0psh31f/Appimages Appimages
      file:///home/t0psh31f/Clan Clan
      file:///home/t0psh31f/Games Games
      file:///home/t0psh31f/Projects Projects
      file:///home/t0psh31f/.config .config
      file:///home/t0psh31f/.hermes .hermes
    '';
  };
}
