{
  config,
  lib,
  pkgs,
  ...
}:
with lib; {
  options.layers.layer-10.system.appimage = {
    enable = mkEnableOption "AppImage support";
  };

  config = mkIf config.layers.layer-10.system.appimage.enable {
    # AppImage support via appimage-run
    environment.systemPackages = with pkgs; [
      appimage-run
    ];

    # Enable FUSE for AppImage
    programs.appimage = {
      enable = true;
      binfmt = true; # Register AppImage files to run directly
    };

    # Required for AppImages
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
