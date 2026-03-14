{ lib, pkgs, ... }:
let
  background-package = pkgs.runCommand "background-image" { } ''
    cp ${./../../../../assets/sddm_background/the-world-of-one-piece_800.gif} $out
  '';
in
{
  # SDDM Display Manager Configuration
  # Reference: https://wiki.hypr.land/Useful-Utilities/Display-Managers/
  services.xserver.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "sugar-dark";
    package = pkgs.kdePackages.sddm;
    extraPackages = with pkgs.kdePackages; [
      qt5compat
      qtdeclarative
      qtsvg
      qtmultimedia
      # GStreamer for multimedia support in themes
      pkgs.gst_all_1.gstreamer
      pkgs.gst_all_1.gst-plugins-base
      pkgs.gst_all_1.gst-plugins-good
      pkgs.gst_all_1.gst-libav
    ];
  };

  environment.systemPackages = with pkgs; [
    (pkgs.writeTextDir "share/sddm/themes/sugar-dark/theme.conf.user" ''
      [General]
      background = "${background-package}"
    '')
  ];

  # Disable greetd to prevent conflicts
  services.greetd.enable = lib.mkForce false;

  # Ensure rtkit and pipewire are enabled for audio in login screen
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
