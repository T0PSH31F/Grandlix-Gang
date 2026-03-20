{ lib, pkgs, ... }:
{
  # SDDM Display Manager Configuration
  # Reference: https://wiki.hypr.land/Useful-Utilities/Display-Managers/
  services.xserver.enable = true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    package = pkgs.kdePackages.sddm;
    extraPackages = with pkgs.kdePackages; [
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
