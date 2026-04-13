{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  options.gaming = {
    enable = mkEnableOption "Gaming support with Proton, Lutris, and emulators";

    enableSteam = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Steam with Proton support";
    };

    enableGamemode = mkOption {
      type = types.bool;
      default = true;
      description = "Enable GameMode for performance optimization";
    };

    enableEmulators = mkOption {
      type = types.bool;
      default = true;
      description = "Enable gaming emulators";
    };
  };

  options.programs.lutris = {
    enable = mkEnableOption "Lutris game manager";
    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "Additional packages for Lutris environments";
    };
  };

  config = mkIf config.gaming.enable {
    # Steam with Proton
    programs.steam = mkIf config.gaming.enableSteam {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      gamescopeSession.enable = true;
      extraCompatPackages = with pkgs; [ proton-ge-bin ];
    };

    # Lutris Configuration (Custom Module)
    programs.lutris = {
      enable = lib.mkDefault true;
      extraPackages = with pkgs; [
        mangohud
        winetricks
        gamescope
        gamemode
        umu-launcher
        steam-run
      ];
    };

    # GameMode for performance
    programs.gamemode = mkIf config.gaming.enableGamemode {
      enable = true;
      enableRenice = true;
      settings = {
        general.renice = 10;
        custom = {
          start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
          end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
        };
      };
    };

    # Enable FUSE for AppImages/Lutris/Mounts
    programs.fuse.enable = true;

    # Gaming packages
    environment.systemPackages =
      with pkgs;
      [
        antimicrox
        bottles
        gamemode
        gamescope
        goverlay
        mangohud
        vintagestory
      ]
      ++ (lib.optionals config.programs.lutris.enable (
        [ pkgs.lutris ] ++ config.programs.lutris.extraPackages
      ))
      ++ (lib.optionals config.gaming.enableEmulators [
        (retroarch.withCores (
          cores: with cores; [
            beetle-psx-hw
            desmume
            dolphin
            flycast
            genesis-plus-gx
            higan
            mgba
            mupen64plus
            ppsspp
            snes9x
          ]
        ))
        bign-handheld-thumbnailer
        cemu
        dolphin-emu
        eden
        fusee-interfacee-tk
        hactool
        joycond
        melonds
        ns-usbloader
        nstool
        nsz
        nx2elf
        pcsx2
        ppsspp
        quark-goldleaf
        rpcs3
        ryubing
        sixpair
        usb-modeswitch
        usb-modeswitch-data
      ]);

    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    boot.kernelModules = [ "ntsync" ];
    boot.kernel.sysctl = {
      "vm.max_map_count" = 2147483642;
    };

    hardware.xone.enable = mkDefault true;
    hardware.xpadneo.enable = mkDefault true;

    services = {
      input-remapper.enable = true;
      system76-scheduler.enable = true;
      udev.packages = with pkgs; [
        ns-usbloader
        quark-goldleaf
      ];
    };

    networking.firewall = {
      allowedTCPPorts = [
        27036
        27037
      ];
      allowedUDPPorts = [
        27031
        27036
      ];
    };

    boot.kernelParams = [ "split_lock_detect=off" ];
  };
}
