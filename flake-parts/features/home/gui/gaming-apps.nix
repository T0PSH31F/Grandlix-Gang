{
  pkgs,
  lib,
  osConfig,
  ...
}:
let
  clanTags = osConfig.machine.tags or [ ];
in
{
  config = lib.mkIf (builtins.elem "gaming" clanTags) {
    home.packages = with pkgs; [
      # Launchers
      cartridges
      lutris
      prismlauncher
      umu-launcher
      steam-run-free
      nero-umu
      eden # switch1 emulator

      # Utility
      protonplus
      protontricks
      nexusmods-app

      # Nintendo Switch / Tools
      nx2elf
      ns-usbloader
      hactool
      fusee-interfacee-tk
      ns-tool
      quark-goldleaf
    ];

    programs.retroarch = {
      enable = true;
      package = pkgs.retroarch;
      cores = {
        snes9x = {
          enable = true;
          package = pkgs.libretro.snes9x2010;
        };
        dolphin = {
          enable = true;
          package = pkgs.libretro.dolphin;
        };
        desmume2015 = {
          enable = true;
          package = pkgs.libretro.desmume2015;
        };
        citra = {
          enable = true;
          package = pkgs.libretro.citra;
        };
        mupen64plus = {
          enable = true;
          package = pkgs.libretro.mupen64plus;
        };
        pcsx2 = {
          enable = true;
          package = pkgs.libretro.pcsx2;
        };
        swanstation = {
          enable = true;
          package = pkgs.libretro.swanstation;
        };
        gpsp = {
          enable = true;
          package = pkgs.libretro.gpsp;
        };
        ppsspp = {
          enable = true;
          package = pkgs.libretro.ppsspp;
        };
        genesis-plus-gx = {
          enable = true;
          package = pkgs.libretro.genesis-plus-gx;
        };
        flycast = {
          enable = true;
          package = pkgs.libretro.flycast;
        };
        mame = {
          enable = true;
          package = pkgs.libretro.mame;
        };
        mgba = {
          enable = true;
          package = pkgs.libretro.mgba;
        };
        scummvm = {
          enable = true;
          package = pkgs.libretro.scummvm;
        };
        atari800 = {
          enable = true;
          package = pkgs.libretro.atari800;
        };
      };
    };
  };
}
