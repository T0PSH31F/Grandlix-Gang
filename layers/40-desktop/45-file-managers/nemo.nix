{ pkgs, lib, config, ... }: {
  options.features.desktop.nemo = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Nemo file manager";
    };
  };

  home = lib.mkIf config.features.desktop.nemo.enable {
    home.packages = with pkgs; [
      nemo-with-extensions
      nemo-fileroller
      nemo-python
    ];

    dconf.settings = {
      "org/nemo/preferences" = {
        show-hidden-files = true;
        default-folder-viewer = "list-view";
      };
    };
  };
}
