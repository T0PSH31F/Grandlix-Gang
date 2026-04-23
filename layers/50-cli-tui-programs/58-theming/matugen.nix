# flake-parts/features/home/cli/theming/matugen.nix
{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.programs.cli-environment.theming.matugen;
  hasNoctalia = config.programs.noctalia-shell.enable or false;

  # Multi-color precise theme mappings for headless/VPS
  allThemes = import ./themes.nix { inherit lib; };
  # Selected theme name from cli-environment.theme
  selectedThemeName = config.programs.cli-environment.theming.theme;
  # Get the actual color set
  themeColors = allThemes.${selectedThemeName} or allThemes."tokyo-night";

  # Helper to fill templates with precise colors
  fillTemplate =
    templatePath: replacements:
    let
      content = builtins.readFile templatePath;
      keys = builtins.attrNames replacements;
      values = builtins.attrValues replacements;
    in
    lib.replaceStrings keys values content;

  # Standard Matugen mapping for our templates
  matugenReplacements = {
    "{{colors.primary.default.hex}}" = themeColors.primary;
    "{{colors.on_primary.default.hex}}" = themeColors.terminal.background;
    "{{colors.secondary.default.hex}}" = themeColors.secondary;
    "{{colors.tertiary.default.hex}}" = themeColors.tertiary;
    "{{colors.error.default.hex}}" = themeColors.error;
    "{{colors.surface.default.hex}}" = themeColors.surface;
    "{{colors.on_surface.default.hex}}" = themeColors.onSurface;
    "{{colors.surface_dim.default.hex}}" = themeColors.terminal.black;
    "{{colors.primary_container.default.hex}}" = themeColors.terminal.cyan;
    "{{colors.secondary_container.default.hex}}" = themeColors.terminal.blue;
    "{{colors.tertiary_container.default.hex}}" = themeColors.terminal.magenta;
  };
in
{
  options.programs.cli-environment.theming.matugen = {
    enable = lib.mkEnableOption "Matugen dynamic theming for CLI tools";

    source = lib.mkOption {
      type = lib.types.enum [
        "wallpaper"
        "noctalia"
        "tokyo-night"
      ];
      default = if hasNoctalia then "noctalia" else "wallpaper";
      description = "Color scheme source for Matugen";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.matugen ];

    home.file = {
      # ── Standard Matugen Templates (Desktop/Dynamic) ────────────────
      ".config/matugen/templates/helix.toml".source = ./templates/helix.toml;

      ".config/matugen/templates/yazi.toml".source = ./templates/yazi.toml;
      ".config/matugen/templates/zellij-colors.kdl".source = ./templates/zellij-colors.kdl;
      ".config/matugen/templates/bat-theme.tmTheme".source = ./templates/bat-theme.tmTheme;
      ".config/matugen/templates/delta.gitconfig".source = ./templates/delta.gitconfig;
      ".config/matugen/templates/fzf-colors.conf".source = ./templates/fzf-colors.conf;
      ".config/matugen/templates/starship.toml".source = ./templates/starship.toml;
      ".config/matugen/templates/btop.theme".source = ./templates/btop.theme;
      ".config/matugen/templates/kitty-colors.conf".source = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/InioX/matugen-themes/main/templates/kitty-colors.conf";
        sha256 = "1fyr9phqvjci1pid0z9nzhima58sq0jnwx53jr7a33hc6w31jsha";
      };

      # ── Headless Static Generator (VPS/1:1 Parity) ──────────────────
      ".config/noctalia/templates/zellij-colors.kdl" = lib.mkIf config.programs.cli-environment.headless {
        text = fillTemplate ./templates/zellij-colors.kdl matugenReplacements;
      };

      ".config/noctalia/templates/yazi.toml" = lib.mkIf config.programs.cli-environment.headless {
        text = fillTemplate ./templates/yazi.toml matugenReplacements;
      };

      ".config/noctalia/templates/fzf-colors.conf" = lib.mkIf config.programs.cli-environment.headless {
        text = fillTemplate ./templates/fzf-colors.conf matugenReplacements;
      };

      ".config/noctalia/templates/starship.toml" = lib.mkIf config.programs.cli-environment.headless {
        text = fillTemplate ./templates/starship.toml matugenReplacements;
      };

      ".config/noctalia/templates/btop.theme" = lib.mkIf config.programs.cli-environment.headless {
        text = fillTemplate ./templates/btop.theme matugenReplacements;
      };

      ".config/noctalia/templates/zsh-colors.sh" = lib.mkIf config.programs.cli-environment.headless {
        text = ''
          # Generated Zsh colors for ${selectedThemeName}
          export PRIMARY="${themeColors.primary}"
          export SECONDARY="${themeColors.secondary}"
          export TERTIARY="${themeColors.tertiary}"
          export ERROR="${themeColors.error}"
          export BG="${themeColors.surface}"
          export FG="${themeColors.onSurface}"
        '';
      };

      # Matugen main configuration (for dynamic use on desktop)
      ".config/matugen/config.toml".text = ''
        [config]
        reload = "all"

        [templates.helix]
        input_path = '~/.config/matugen/templates/helix.toml'
        output_path = '~/.config/helix/themes/matugen.toml'

        [templates.yazi]
        input_path = '~/.config/matugen/templates/yazi.toml'
        output_path = '~/.config/yazi/theme.toml'

        [templates.zellij]
        input_path = '~/.config/matugen/templates/zellij-colors.kdl'
        output_path = '~/.config/zellij/themes/matugen.kdl'
        post_hook = 'pkill -SIGUSR1 zellij'

        [templates.bat]
        input_path = '~/.config/matugen/templates/bat-theme.tmTheme'
        output_path = '~/.config/bat/themes/matugen.tmTheme'
        post_hook = 'bat cache --build'

        [templates.delta]
        input_path = '~/.config/matugen/templates/delta.gitconfig'
        output_path = '~/.config/delta/matugen-theme.gitconfig'

        [templates.fzf]
        input_path = '~/.config/matugen/templates/fzf-colors.conf'
        output_path = '~/.config/fzf/matugen.conf'

        [templates.starship]
        input_path = '~/.config/matugen/templates/starship.toml'
        output_path = '~/.config/starship-matugen.toml'

        [templates.btop]
        input_path = '~/.config/matugen/templates/btop.theme'
        output_path = '~/.config/btop/themes/matugen.theme'

        [templates.kitty]
        input_path = '~/.config/matugen/templates/kitty-colors.conf'
        output_path = '~/.config/kitty/colors.conf'
        post_hook = 'pkill -SIGUSR1 kitty'
      '';
    };
  };
}
