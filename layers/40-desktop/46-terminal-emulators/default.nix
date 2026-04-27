{ lib, config, ... }: {
  options.features.desktop.terminals = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable desktop terminal emulators";
    };
  };

  home = {
    imports = lib.optionals config.features.desktop.terminals.enable [
      ./ghostty.nix
      ./waveterm.nix
    ];
  };
}
