{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  options.layers.layer-10.system.appimage = {
    enable = mkEnableOption "AppImage support";
  };

  config = mkIf config.layers.layer-10.system.appimage.enable {
    # AppImage support via appimage-run
    environment.systemPackages = with pkgs; [
      appimage-run
      appimageupdate-qt
      libappimage
      squashfs-tools-ng
      squashfsTools
      squashfuse
    ];

    # Enable FUSE for AppImage
    programs.appimage = {
      enable = true;
      binfmt = false; # We use manual binfmt below instead to avoid SquashFS errors
    };

    # Required for AppImages (manual binfmt prevents SquashFS superblock errors)
    boot.binfmt.registrations.appimage = {
      wrapInterpreterInShell = false;
      interpreter = "${pkgs.appimage-run}/bin/appimage-run";
      recognitionType = "magic";
      offset = 0;
      mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
      magicOrExtension = ''\x7fELF....AI\x02'';
    };

  };
}
