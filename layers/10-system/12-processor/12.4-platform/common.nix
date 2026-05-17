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

    # ============================================================================
    # DISK AUTOMOUNTING
    # ============================================================================

    # Enable udisks2 service
    services.udisks2.enable = mkIf config.layers.layer-10.system.peripherals.automount.enable true;

    # Add udiskie and udisks to system packages

    # ============================================================================
    # RGB LIGHTING (OpenRGB)
    # ============================================================================

    services.hardware.openrgb = mkIf config.layers.layer-10.system.peripherals.openrgb.enable {
      enable = true;
      #  motherboard = "amd"; # or "intel" - auto-detected in most cases
    };

    # Enable I2C for RGB RAM and motherboard control
    hardware.i2c.enable = mkIf (
      config.layers.layer-10.system.peripherals.openrgb.enable && config.layers.layer-10.system.peripherals.openrgb.enableI2C
    ) true;

    # Enable Corsair RGB hardware support
    hardware.ckb-next.enable = mkIf config.layers.layer-10.system.peripherals.corsair.enable true;

    # Add hardware packages
    environment.systemPackages =
      (lib.optionals config.layers.layer-10.system.peripherals.automount.enable (
        with pkgs;
        [
          udisks
        ]
      ))
      ++ (lib.optionals config.layers.layer-10.system.peripherals.openrgb.enable [ pkgs.openrgb ])
      ++ (with pkgs; [
        logitech-udev-rules
        solaar
      ]);

    # Add user to i2c group for RGB control
    # This will need to be added to user configuration
    # users.users.<username>.extraGroups = [ "i2c" ];

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

    # USB automounting
    services.devmon.enable = mkIf config.layers.layer-10.system.peripherals.automount.enable true;
    services.gvfs.enable = mkIf config.layers.layer-10.system.peripherals.automount.enable true;

    # Storage optimization
    services.fstrim.enable = true; # SSD TRIM support
  };
}
