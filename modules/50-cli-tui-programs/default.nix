# flake-parts/features/home/cli/default.nix
{ config, lib, ... }:

let
  cfg = config.programs.cli-environment;
in
{
  imports = [
    ./52-editors/fallbacks.nix
    ./52-editors/helix.nix
    ./56-file-managers/alternatives.nix
    ./56-file-managers/superfile.nix
    ./56-file-managers/yazi.nix
    ./59-integrations/keybindings.nix
    ./59-integrations/yazelix-style.nix
    # ./54-multiplexers/tmux.nix
    ./54-multiplexers/zellij.nix
    ./55-prompt/starship.nix
    ./57-services
    ./51-shells/bash.nix
    ./51-shells/common.nix
    ./51-shells/zsh.nix
    ./58-theming/matugen.nix
    ./53-tools/fzf.nix
    ./53-tools/git.nix
    ./53-tools/gpg.nix
    ./53-tools/modern-utils.nix
    ./53-tools/nix-tools.nix
    ./53-tools/python.nix
    ./53-tools/system-utils.nix
    ./59-integrations/yazelix.nix
    ./58-theming/vivid.nix
  ];

  options.programs.cli-environment = {
    enable = lib.mkEnableOption "Complete CLI/TUI environment";

    theming = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable dynamic theming for CLI tools";
      };
      theme = lib.mkOption {
        type = lib.types.enum [
          "Catppuccin Lavender"
          "Cherry Blossom"
          "Cyberpunk"
          "Everdeer"
          "Everforest"
          "GitHub Dark"
          "Gruber Darker"
          "GruvboxAlt"
          "Hexa34C"
          "Lilac AMOLED"
          "Miasma"
          "Monochrome"
          "NaySayer"
          "Noctalia legacy"
          "Oasis Abyss"
          "Occult Umbral"
          "One"
          "Osaka jade"
          "Oxide"
          "Oxocarbon"
          "Peche"
          "Rose Pine Moon"
          "Rosey AMOLED"
          "Solarized"
          "Tokyo Night Moon"
          "Vesper"
          "tokyo-night"
        ];
        default = "tokyo-night";
        description = "Static theme to use in headless mode";
      };
    };

    shells = {
      zsh.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Zsh with full Powerlevel10k configuration";
      };
      bash.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Enable Bash configuration";
      };
    };

    yazelixIntegration.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Helix + Yazi + Zellij integration";
    };

    modernTools.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable modern CLI tool replacements (bat, eza, ripgrep, etc.)";
    };

    nixTools.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Nix-specific CLI tools";
    };

    pythonTools.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Python and related tools (uv, etc.)";
    };

    headless = lib.mkEnableOption "Headless/VPS environment optimizations";
  };

  config = lib.mkIf cfg.enable {
    programs.cli-environment.theming.matugen.enable = cfg.theming.enable;
    
    # Simple direct toggle for headless color sourcing
    programs.cli-environment.theming.matugen.source = lib.mkIf cfg.headless (lib.mkForce "tokyo-night");

    programs.vivid.matugen = {
      enable = true;
      outputColorMode = "24-bit";
      # matugenIntegration is implied by enabling this module
    };
  };
}
