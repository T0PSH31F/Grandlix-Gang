{ lib, ... }: {
  options.layers.registry = lib.mkOption {
    type = lib.types.attrsOf lib.types.path;
    default = {
      # 10-system
      "foundation" = ../11-foundation;
      "processor" = ../12-processor;
      "users" = ../13-users;
      "virtualization" = ../14-virtualization;
      "impermanence" = ../15-filesystem/impermanence.nix;
      "mobile" = ../16-mobile;
      "flatpak" = ../17-app-runtimes/flatpak.nix;
      "peripherals" = ../18-peripherals;
      "optimizations" = ../19-optimizations;
      
      # 20-services
      # "networking" = ../../20-services/21-networking;
      # ... can be expanded
    };
    description = "Registry of layer names to paths, allowing tag profiles to import by name rather than relative path";
    readOnly = true;
  };
}
