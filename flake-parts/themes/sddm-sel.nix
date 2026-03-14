{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.themes.sddm-sel;

  # SEL theme package (Qt5 based)
  sddm-sel-theme = pkgs.stdenv.mkDerivation {
    pname = "sddm-sel-theme";
    version = "1.0";
    src = pkgs.fetchFromGitHub {
      owner = "leonardochappuis";
      repo = "sddmsel";
      rev = "e9860d88899d4fdfaea3cffe570e6ad55e25cf15";
      sha256 = "sha256-izrDuyOMPvEZt9c9Qs1sioqRKL+3M4S0RUUMMHhPK2c=";
    };
    installPhase = ''
      mkdir -p $out/share/sddm/themes
      cp -r sel-basic $out/share/sddm/themes/sel-basic
      cp -r sel-shaders $out/share/sddm/themes/sel-shaders
    '';
  };
in
{
  options.themes.sddm-sel = {
    enable = mkEnableOption "SDDM SEL theme (Serial Experiments Lain inspired)";

    variant = mkOption {
      type = types.enum [
        "basic"
        "shaders"
      ];
      default = "shaders";
      description = ''
        Which variant of the SEL theme to use:
        - "basic" - Without shader effects (lighter on resources)
        - "shaders" - With shader effects (more visual effects)
      '';
    };
  };

  config = mkIf cfg.enable {
    # Assertion: Only one SDDM theme can be enabled at a time
    assertions = [
      {
        assertion = !(config.themes.sddm-lain.enable or false);
        message = "Cannot enable both themes.sddm-sel and themes.sddm-lain. Please disable one.";
      }
    ];

    # SDDM SEL theme configuration (Qt5 based)
    # Install theme and dependencies to system
    environment.systemPackages = [
      sddm-sel-theme
    ];
  };
}
