{ config, lib, ... }:
let
  inherit (import ../../layers/80-lib/81-helpers/mkDendriticModule.nix { inherit lib; })
    mkDendriticModule
    ;
  cfg = config.layers.layer-50.cli;
in
{
  imports = [
    # Multi-class modules (wrapped)
    (mkDendriticModule "fallbacks" ./52-editors/fallbacks.nix)
    (mkDendriticModule "nixvim" ./52-editors/nixvim)
    (mkDendriticModule "helix" ./52-editors/helix.nix)
    (mkDendriticModule "gedit" ./52-editors/gedit.nix)
    (mkDendriticModule "alternatives" ./56-file-managers/alternatives.nix)
    (mkDendriticModule "superfile" ./56-file-managers/superfile.nix)
    (mkDendriticModule "yazi" ./56-file-managers/yazi.nix)
    (mkDendriticModule "keybindings" ./59-integrations/keybindings.nix)
    (mkDendriticModule "yazelix-style" ./59-integrations/yazelix-style.nix)
    (mkDendriticModule "zellij" ./54-multiplexers/zellij.nix)
    (mkDendriticModule "tmux" ./54-multiplexers/tmux.nix)
    (mkDendriticModule "starship" ./55-prompt/starship.nix)
    (mkDendriticModule "bash" ./51-shells/bash.nix)
    (mkDendriticModule "common-shell" ./51-shells/common.nix)
    (mkDendriticModule "zsh" ./51-shells/zsh.nix)
    (mkDendriticModule "matugen" ./58-theming/matugen.nix)
    (mkDendriticModule "fzf" ./53-tools/fzf.nix)
    (mkDendriticModule "git" ./53-tools/git.nix)
    (mkDendriticModule "himalaya" ./53-tools/himalaya.nix)
    (mkDendriticModule "gpg" ./53-tools/gpg.nix)
    (mkDendriticModule "modern-utils" ./53-tools/modern-utils.nix)
    (mkDendriticModule "nix-tools" ./53-tools/nix-tools.nix)
    (mkDendriticModule "python" ./53-tools/python.nix)
    (mkDendriticModule "system-utils" ./53-tools/system-utils.nix)
    (mkDendriticModule "yazelix" ./59-integrations/yazelix.nix)
    (mkDendriticModule "vivid" ./58-theming/vivid.nix)
    (mkDendriticModule "terminal-toys" ./58-theming/terminal-toys.nix)
    ./packages-dev.nix

    # Tiered sub-entry points
    ./57-services
  ];

  options.layers.layer-50.cli = {
    enable = lib.mkEnableOption "Complete CLI/TUI environment" // {
      default = true;
    };

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
          "Tokyo Night Moon"
          "Tokyo Night"
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
      default = false;
      description = "Enable Helix + Yazi + Zellij integration (deprecated)";
    };

    modernTools.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable modern CLI tool replacements (bat, eza, ripgrep, etc.)";
    };

    nixToolsHM.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable Nix-specific CLI tools (Home Manager side)";
    };

    pythonTools.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Python and related tools (uv, etc.)";
    };

    terminal-toys = {
      enable = lib.mkEnableOption "Fun terminal toys (cmatrix, cbonsai, etc.)";
    };

    headless = lib.mkEnableOption "Headless/VPS environment optimizations";
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.t0psh31f = {
      imports = [ ../80-lib/81-helpers/hm-bridge.nix ];
      config = {
        programs.cli-environment = {
          enable = true;
          theming.enable = cfg.theming.enable;
          headless = cfg.headless;
        };
      };
    };

    # Matugen disabled — Noctalia owns all runtime theming (wallpaper → Material You colors)
    # Matugen templates conflicted with Noctalia's own template system for the same apps
    layers.layer-50.cli.theming.matugen.enable = lib.mkDefault false;
  };
}
