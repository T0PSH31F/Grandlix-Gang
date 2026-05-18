{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  cfg = config.layers.layer-50.cli.yazelixIntegration;
in
{
  # Option is defined in layers/50-cli-tui-programs/default.nix as yazelixIntegration

  home = lib.mkIf cfg.enable {
    _module.args.lib = lib.extend (
      final: prev: {
        hm = inputs.home-manager.lib.hm;
      }
    );

    imports = [ inputs.yazelix-hm.homeManagerModules.default ];

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
      nixfmt
      nushell
      onefetch
      ouch
      oxlint
      p7zip
      pandoc
      poppler-utils
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
      default_shell = "zsh";
      terminals = [
        "ghostty"
        "kitty"
        "wezterm"
      ];
      terminal_config_mode = "user";
      transparency = "high";
    };
  };
}
