{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [ inputs.yazelix-hm.homeManagerModules.default ];

  options.features.home.cli.yazelix.enable = lib.mkEnableOption "Yazelix terminal environment";

  config = lib.mkIf config.features.home.cli.yazelix.enable {
    home.packages = with pkgs; [
      biome
      bun
      carapace
      erdtree
      fd
      ffmpeg
      gh
      imagemagick
      jq
      lazygit
      markdown-oxide
      nil
      nixd
      nixfmt-rfc-style
      nushell
      onefetch
      ouch
      oxlint
      p7zip
      pandoc
      poppler-utils
      python3
      python3Packages.ipython
      ripgrep
      ruff
      tinymist
      ty
      typescript-language-server
      typst
      uv
      yaml-language-server
      zsh
    ];

    programs.yazelix = {
      enable = true;

      debug_mode = false;
      skip_welcome_screen = false;
      show_macchina_on_welcome = true;

      editor_command = null;
      enable_sidebar = true;

      default_shell = "zsh";

      terminals = [
        "ghostty"
        "kitty"
        "wezterm"
      ];
      terminal_config_mode = "user";
      ghostty_trail_color = "party";
      ghostty_trail_effect = "sweep";
      ghostty_mode_effect = "sonic_boom";
      transparency = "high";

      disable_zellij_tips = true;
      zellij_rounded_corners = true;
      support_kitty_keyboard_protocol = false;
      zellij_theme = "default";
      zellij_widget_tray = [
        "term"
        "cpu"
        "ram"
      ];
      persistent_sessions = true;
      session_name = "Thousand-Sunny";
      zellij_default_mode = "normal";

      yazi_plugins = [
        "git"
        "starship"
      ];
      yazi_theme = "default";
      yazi_sort_by = "alphabetical";
    };
  };
}
