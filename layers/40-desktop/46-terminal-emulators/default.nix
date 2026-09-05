{ lib, config, ... }:
{
  options.layers.layer-40.desktop.terminals = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable desktop terminal emulators";
    };
  };

  home = { pkgs, ... }: {
    imports = lib.optionals config.layers.layer-40.desktop.terminals.enable [
      ./ghostty.nix
      ./waveterm.nix
      ./kitty.nix
    ];
    home.packages = lib.optionals config.layers.layer-40.desktop.terminals.enable (with pkgs; [
      warp-terminal
    ]);
  };
}
