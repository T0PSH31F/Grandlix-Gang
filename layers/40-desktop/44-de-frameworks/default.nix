{ lib, config, ... }: {
  options.features.desktop.frameworks = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable desktop frameworks";
    };

    portals = {
      enable = lib.mkEnableOption "Desktop portals for Wayland compositors";
      extraPortals = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        default = [ ];
        description = "Additional XDG desktop portals to enable";
      };
    };

    vicinae = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = builtins.elem "desktop" (config.machine.tags or [ ]);
        description = "Enable Vicinae launcher";
      };
    };
  };

  imports = [
    ./portals.nix
  ];

  home = {
    imports = [
      ./vicinae.nix
    ];
  };
}
