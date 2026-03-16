# flake-parts/features/home/cli/yazelix.nix
#
# Comprehensive Yazelix Home Manager module configuration.
# This configures the yazelix.toml that controls the Yazelix terminal environment
# (Zellij + Yazi + Helix integrated IDE-like experience).
#
# Reference: https://github.com/luccahuguet/yazelix
# All options mirror the locked version (rev 7cf826b) of the upstream module.
#
{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [ inputs.yazelix.homeManagerModules.default ];

  options.features.home.cli.yazelix.enable = lib.mkEnableOption "Yazelix terminal environment";

  config = lib.mkIf config.features.home.cli.yazelix.enable {
    # ──────────────────────────────────────────────────────────────────────────
    # Dependencies
    # ──────────────────────────────────────────────────────────────────────────
    # Yazelix needs nushell available even when using a different default shell.
    home.packages = [
      pkgs.nushell
      pkgs.zsh
    ];

    programs.yazelix = {
      enable = true;

      # ════════════════════════════════════════════════════════════════════════
      # [core] — Build & dependency settings
      # ════════════════════════════════════════════════════════════════════════

      # Install recommended productivity tools (~350MB): lazygit, carapace
      recommended_deps = true;

      # Install Yazi file preview extensions (~125MB): p7zip, jq, fd, ripgrep, poppler
      yazi_extensions = true;

      # Install heavy media processing tools (~1GB): ffmpeg, imagemagick
      yazi_media = true;

      # Concurrent Nix build jobs
      # Options: "auto", "max", "max_minus_one", "half", "quarter", or a number like "8"
      max_jobs = "half";

      # CPU cores per Nix build
      # Options: "max", "max_minus_one", "half", "quarter", or a number like "2"
      build_cores = "2";

      # Rebuild output verbosity for launch/restart/refresh
      # Options: "quiet" | "normal" | "full"
      refresh_output = "normal";

      # Enable verbose debug logging in the shellHook
      debug_mode = false;

      # When true, welcome info is logged instead of displayed
      skip_welcome_screen = false;

      # Show system info on welcome screen (uses macchina)
      show_macchina_on_welcome = true;

      # ════════════════════════════════════════════════════════════════════════
      # [helix] — Helix editor build configuration
      # ════════════════════════════════════════════════════════════════════════

      # Build mode for Helix
      #   "release" — Use Helix from nixpkgs (stable)
      #   "source"  — Build from Helix flake (bleeding edge)
      helix_mode = "release";

      # Custom Helix runtime path (only if using custom/nonstandard Helix build)
      # Must match your Helix binary version to avoid startup errors.
      # Example: "/home/user/helix/runtime"
      # helix_runtime_path = null;

      # ════════════════════════════════════════════════════════════════════════
      # [editor] — Editor command & sidebar
      # ════════════════════════════════════════════════════════════════════════

      # Editor command — controls what yazelix uses as the editor
      #   null       — Use yazelix's Nix-provided Helix (recommended, full integration)
      #   "hx"       — Use system Helix from PATH
      #   "nvim"     — Use Neovim (first-class support)
      #   "vim"      — Basic integration only
      editor_command = null;

      # Enable the Yazi file tree sidebar
      enable_sidebar = true;

      # ════════════════════════════════════════════════════════════════════════
      # [shell] — Shell configuration
      # ════════════════════════════════════════════════════════════════════════

      # Default shell for Zellij sessions
      # Options: "nu" | "bash" | "fish" | "zsh"
      default_shell = "zsh";

      # Additional shells to install beyond nu/bash
      # Options: "fish", "zsh"
      extra_shells = [
        "zsh"
      ];

      # ════════════════════════════════════════════════════════════════════════
      # [terminal] — Terminal emulator configuration
      # ════════════════════════════════════════════════════════════════════════

      # Ordered terminal list (first = primary, rest = fallbacks)
      # Options: "ghostty" | "wezterm" | "kitty" | "alacritty" | "foot"
      terminals = [
        "ghostty"
        "kitty"
        "wezterm"
      ];

      # Let yazelix manage terminal installation via Nix
      # Set false to use system-installed terminals only
      manage_terminals = false;

      # How yazelix selects terminal configs:
      #   "yazelix" — Always use Yazelix-provided configs (default)
      #   "auto"    — Prefer user configs if present, otherwise Yazelix configs
      #   "user"    — Always use user configs (e.g., ~/.config/ghostty/config)
      terminal_config_mode = "auto";

      # Ghostty cursor color palette (also affects Kitty cursor-trail fallback)
      # Options: "blaze" | "snow" | "cosmic" | "ocean" | "forest" | "sunset"
      #        | "neon" | "party" | "eclipse" | "dusk" | "orchid" | "reef"
      #        | "inferno" | "random"
      ghostty_trail_color = "party";

      # Ghostty cursor movement trail effect
      # Options: "tail" | "warp" | "sweep" | "random" | null (disable)
      ghostty_trail_effect = "sweep";

      # Ghostty mode-change effect (e.g., normal ↔ insert)
      # Options: "ripple" | "sonic_boom" | "rectangle_boom"
      #        | "ripple_rectangle" | "random" | null (disable)
      ghostty_mode_effect = "sonic_boom";

      # Terminal transparency level (applies to all terminals)
      #   "none"       — opacity 1.00
      #   "very_low"   — opacity 0.95
      #   "low"        — opacity 0.90
      #   "medium"     — opacity 0.85
      #   "high"       — opacity 0.80
      #   "very_high"  — opacity 0.70
      #   "super_high" — opacity 0.60
      transparency = "high";

      # ════════════════════════════════════════════════════════════════════════
      # [zellij] — Zellij terminal multiplexer settings
      # ════════════════════════════════════════════════════════════════════════

      # Disable Zellij tips popup on startup
      disable_zellij_tips = true;

      # Enable rounded corners for Zellij pane frames
      zellij_rounded_corners = true;

      # Enable Kitty keyboard protocol in Zellij
      # Disable if dead keys stop working in your terminal (e.g. Ghostty)
      support_kitty_keyboard_protocol = false;

      # Zellij color theme
      # Set to "default" to allow matugen/Noctalia theme to be picked up
      # from ~/.config/zellij/themes/matugen.kdl
      #
      # Built-in dark themes:
      #   ansi, ao, atelier-sulphurpool, ayu_mirage, ayu_dark,
      #   catppuccin-frappe, catppuccin-macchiato, cyber-noir, blade-runner,
      #   retro-wave, dracula, everforest-dark, gruvbox-dark, iceberg-dark,
      #   kanagawa, lucario, menace, molokai-dark, night-owl, nightfox, nord,
      #   one-half-dark, onedark, solarized-dark, tokyo-night-dark,
      #   tokyo-night-storm, tokyo-night, vesper
      #
      # Built-in light themes:
      #   ayu_light, catppuccin-latte, everforest-light, gruvbox-light,
      #   iceberg-light, dayfox, pencil-light, solarized-light, tokyo-night-light
      zellij_theme = "default";

      # Zjstatus widget tray — widgets shown in the Zellij status bar
      # Available: "layout", "editor", "shell", "term", "cpu", "ram"
      zellij_widget_tray = [
        "layout"
        "term"
        "cpu"
        "ram"
      ];

      # Enable persistent Zellij sessions (reattach on restart)
      persistent_sessions = true;

      # Session name for persistent sessions
      session_name = "Thousand-Sunny";

      # Startup mode for new Zellij sessions
      #   "normal" — Starts unlocked (yazelix default)
      #   "locked" — Starts in locked mode (better for nested TUIs)
      zellij_default_mode = "normal";

      # ════════════════════════════════════════════════════════════════════════
      # [yazi] — Yazi file manager settings (yazelix-managed config)
      # ════════════════════════════════════════════════════════════════════════

      # Plugins to load (auto-generates require("plugin"):setup() calls)
      # Core plugins (auto_layout, sidebar_status) are always loaded.
      # Bundled: "git" (git status icons), "starship" (prompt in yazi header)
      yazi_plugins = [
        "git"
        "starship"
      ];

      # Yazi color theme (flavor)
      # Set to "default" to allow matugen theme from
      # ~/.config/yazi/theme.toml to take effect.
      # Or use built-in flavors: "dracula", "catppuccin-macchiato",
      # "tokyo-night", "random-dark", "random-light", etc.
      # Browse: https://github.com/yazi-rs/flavors
      yazi_theme = "default";

      # Default file sorting method
      # Options: "alphabetical" | "natural" | "modified" | "created" | "size"
      yazi_sort_by = "alphabetical";

      # ════════════════════════════════════════════════════════════════════════
      # [ascii] — Welcome screen ASCII art
      # ════════════════════════════════════════════════════════════════════════

      # ASCII art display mode on welcome screen
      # Options: "static" | "animated"
      ascii_art_mode = "animated";

      # ════════════════════════════════════════════════════════════════════════
      # [packs] — Language & tool bundles
      # ════════════════════════════════════════════════════════════════════════

      # Packs to enable (must match keys in pack_declarations)
      pack_names = [
        "ai_agents"
        "ai_tools"
        "file-management"
        "git"
        "python"
        "ts"
        "writing"
        "config"
        # "jj"
        # "rust"
        # "rust_extra"
        "nix"
        # "go"
        # "go_extra"
        # "kotlin"
      ];

      # Pack declarations mapping names to nixpkgs package strings
      # Customize these to add/remove tools from each pack.
      # Search packages at: https://search.nixos.org/packages
      pack_declarations = {
        # AI coding agents
        ai_agents = [
          "claude-code"
          "codex"
          "opencode"
          "amp"
          "cursor-agent"
          "goose-cli"
        ];
        # AI support tools: analytics, review, utilities
        ai_tools = [
          "coderabbit-cli"
          "ccusage"
          "ccusage-amp"
          "ccusage-codex"
          "ccusage-opencode"
          "beads"
          "openclaw"
          "picoclaw"
          "zeroclaw"
        ];
        # Configuration tools
        config = [
          "mpls"
          "yaml-language-server"
        ];
        # File management utilities
        file-management = [
          "ouch"
          "erdtree"
          "serpl"
        ];
        # Git tools
        git = [
          "onefetch"
          "gh"
          "prek"
        ];
        # Jujutsu VCS
        jj = [
          "jujutsu"
          "lazyjj"
          "jjui"
        ];
        # Python development
        python = [
          "ruff"
          "uv"
          "ty"
          "python3Packages.ipython"
          "python3"
        ];
        # Rust development
        rust = [
          "cargo-edit"
          "cargo-watch"
          "cargo-audit"
        ];
        # Rust extras
        rust_extra = [
          "cargo-update"
          "cargo-binstall"
          "cargo-nextest"
        ];
        # Nix tools
        nix = [
          "nil"
          "nixd"
          "nixfmt"
        ];
        # TypeScript/JavaScript
        ts = [
          "nodePackages.typescript-language-server"
          "biome"
          "oxlint"
          "bun"
        ];
        # Go development
        go = [
          "gopls"
          "golangci-lint"
        ];
        # Go extras
        go_extra = [
          "delve"
          "air"
          "govulncheck"
        ];
        # Kotlin development
        kotlin = [
          "kotlin-language-server"
          "ktlint"
          "detekt"
          "gradle"
        ];
        # Writing & documentation
        writing = [
          "typst"
          "tinymist"
          "pandoc"
          "markdown-oxide"
        ];
      };

      # Additional packages beyond packs (use `with pkgs;` in the caller)
      user_packages = [ ];
    };

    # ══════════════════════════════════════════════════════════════════════════
    # Matugen/Noctalia integration for yazelix-managed configs
    # ══════════════════════════════════════════════════════════════════════════
    # Yazelix's zellij config merger reads ~/.config/zellij/config.kdl as the
    # user layer. With terminal_config_mode = "auto", the matugen-generated
    # theme at ~/.config/zellij/themes/matugen.kdl is picked up automatically.
    #
    # For yazi, matugen writes to ~/.config/yazi/theme.toml which is the
    # standard location. When yazi_theme = "default", yazelix won't override it.
    #
    # The existing matugen.nix templates handle all theme generation:
    #   - Helix: ~/.config/helix/themes/matugen.toml
    #   - Zellij: ~/.config/zellij/themes/matugen.kdl
    #   - Yazi: ~/.config/yazi/theme.toml
  };
}
