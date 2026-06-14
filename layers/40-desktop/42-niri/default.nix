{
  osConfig ? config,
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
{
  imports = [
    inputs.niri.nixosModules.niri
  ];

  options.layers.layer-40.desktop.niri = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Niri WM";
    };
  };

  nixos = lib.mkIf osConfig.layers.layer-40.desktop.niri.enable {
    programs.niri = {
      enable = true;
      package = inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri-stable;
    };

    programs.uwsm = {
      enable = true;
      waylandCompositors.niri = {
        prettyName = "Niri";
        comment = "Niri compositor managed by UWSM";
        binPath = "/run/current-system/sw/bin/niri";
      };
    };
  };

  home = {
    imports = [
      ./settings.nix
      ./keybinds.nix
      ./outputs.nix
      ./uwsm.nix
    ];

    home.packages = lib.mkIf osConfig.layers.layer-40.desktop.niri.enable (
      with pkgs;
      [
        xwayland-satellite
        nautilus
        alacritty
        fuzzel
        swappy
      ]
    );
  };
}
