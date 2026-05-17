{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.layers.layer-50.cli;
in
{
  home = lib.mkIf (cfg.enable && cfg.modernTools.enable) {
    programs = {
      bat = {
        enable = true;
        config.theme = lib.mkIf (cfg.theming.enable && !(config.stylix.enable or false)) "matugen";
      };
      ripgrep.enable = true;
      jq.enable = true;
      btop = {
        enable = true;
        settings.color_theme = lib.mkIf (cfg.theming.enable && !(config.stylix.enable or false)) "matugen";
      };
      eza = {
        enable = true;
        enableZshIntegration = true;
        enableBashIntegration = true;
        git = true;
        icons = "always";
        extraOptions = [ "-a" "-1" ];
      };
      zoxide = {
        enable = true;
        enableZshIntegration = true;
        enableBashIntegration = true;
        options = [ "--cmd cd" ];
      };
      direnv = {
        enable = true;
        enableZshIntegration = true;
        enableBashIntegration = true;
        nix-direnv.enable = true;
      };
      fd = {
        enable = true;
        hidden = true;
        ignores = [ ".git" ".DS_Store" ];
      };
      pay-respects = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
        options = [ "--alias" "f" ];
      };
      carapace = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
      };
    };
    home.packages = with pkgs; [
      bar cloudflare-cli cpx detox procs dust duf tokei hyperfine
      tealdeer trash-cli trippy rsyncy stripe-cli supabase-cli pv
      pq-cli progress xxh wrangler
    ];
  };
}
