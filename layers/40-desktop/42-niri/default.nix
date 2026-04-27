{ osConfig ? config,  pkgs, lib, config, ... }: {
  options.features.desktop.niri = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Niri WM";
    };
  };

  home = lib.mkIf osConfig.features.desktop.niri.enable {
    imports = [
      ./settings.nix
      ./keybinds.nix
      ./outputs.nix
      ./uwsm.nix
    ];

    home.packages = with pkgs; [
      xwayland-satellite
      nautilus
      alacritty
      fuzzel
      swappy
    ];
  };
}
