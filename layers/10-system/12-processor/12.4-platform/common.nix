{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
{
  options.layers.layer-10.system.hardware = {
    # Kernel selection
    kernel = mkOption {
      type = types.enum [
        "latest"
        "cachyos"
        "zen"
      ];
      default = "latest";
      description = ''
        Select which kernel to use:
        - latest: Latest stable kernel from nixpkgs
        - cachyos: CachyOS optimized kernel for performance
        - zen: Zen kernel for desktop responsiveness
      '';
    };
  };

  config = {
    # ============================================================================
    # KERNEL CONFIGURATION
    # ============================================================================

    boot.kernelPackages = mkMerge [
      # Latest stable kernel (default)
      (mkIf (config.layers.layer-10.system.hardware.kernel == "latest") pkgs.linuxPackages_latest)

      # CachyOS kernel - optimized for performance
      (mkIf (config.layers.layer-10.system.hardware.kernel == "cachyos") pkgs.linuxPackages_cachyos)

      # Zen kernel - optimized for desktop/responsiveness
      (mkIf (config.layers.layer-10.system.hardware.kernel == "zen") pkgs.linuxPackages_zen)
    ];

    # Automounting extracted to 18-peripherals/automount.nix

    # RGB and Logitech extracted to 18-peripherals/

    # ============================================================================
    # GENERAL HARDWARE SUPPORT
    # ============================================================================

    # Enable firmware updates
    services.fwupd.enable = true;

    # Enable CPU microcode updates
    hardware.cpu.intel.updateMicrocode = lib.mkDefault true;
    hardware.cpu.amd.updateMicrocode = lib.mkDefault true;

    # Enable redistributable firmware (doesn't require allowUnfree)
    hardware.enableRedistributableFirmware = true;

    # Graphics support
    hardware.graphics = {
      enable = true;
      enable32Bit = true; # For 32-bit applications and games
    };



    # Storage optimization
    services.fstrim.enable = true; # SSD TRIM support
  };
}
