{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.features.identity.themes.grub-lain = {
    enable = lib.mkEnableOption "Lain GRUB theme";
    efiInstallAsRemovable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to install GRUB into the default EFI fallback path (/EFI/BOOT/BOOTX64.EFI).";
    };
  };

  config = lib.mkIf config.features.identity.themes.grub-lain.enable {
    # Use the GRUB 2 boot loader with Lain theme
    boot.loader.grub = {
      enable = true;
      configurationLimit = 10;
      device = "nodev"; # EFI systems use nodev
      efiSupport = true;
      efiInstallAsRemovable = config.features.identity.themes.grub-lain.efiInstallAsRemovable;
      useOSProber = true;

      # Lain theme configuration
      theme = pkgs.stdenv.mkDerivation {
        pname = "lain-grub-theme";
        version = "1.0";

        # Use fetchFromGitHub for reproducibility
        src = pkgs.fetchFromGitHub {
          owner = "uiriansan";
          repo = "LainGrubTheme";
          rev = "main"; # Use main branch as default
          sha256 = "117872vbaj19ynnjf4j49zs7cf5z3d6xk1jdiha49wbnaai0sg40";
        };

        installPhase = ''
          mkdir -p $out
          cp -r lain/* $out/
        '';
      };
    };

    # Disable systemd-boot when using GRUB theme (use mkForce to override base.nix)
    boot.loader.systemd-boot.enable = lib.mkForce false;
    boot.loader.efi.canTouchEfiVariables = lib.mkForce (!config.features.identity.themes.grub-lain.efiInstallAsRemovable);
  };
}
