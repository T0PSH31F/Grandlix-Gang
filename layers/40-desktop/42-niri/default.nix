{ osConfig ? config, pkgs, lib, config, inputs, ... }: {
  options.layers.layer-40.desktop.niri = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Niri WM";
    };
  };

  home = {
    imports = [
      inputs.niri.homeModules.config
      ./settings.nix
      ./keybinds.nix
      ./outputs.nix
      ./uwsm.nix
    ];

    home.packages = lib.mkIf osConfig.layers.layer-40.desktop.niri.enable (with pkgs; [
      xwayland-satellite
      nautilus
      alacritty
      fuzzel
      swappy
    ]);
  };
}
