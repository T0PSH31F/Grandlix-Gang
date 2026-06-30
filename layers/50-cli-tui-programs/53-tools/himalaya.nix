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
  home =
    { config, ... }:
    lib.mkIf cfg.enable {
      home.packages = with pkgs; [
        himalaya
      ];

      # Generate himalaya config with app passwords sourced from SOPS secrets.
      # The backend.auth.cmd reads the secret file at runtime — never stored in
      # the nix store or hardcoded in any derivation.
      xdg.configFile."himalaya/config.toml".text =
        let
          # Access sops secrets from home-manager config (not module-level config)
          wrighterik77Pass = config.sops.secrets.gmail_app_password_wrighterik77.path;
          lovelainautomationsPass = config.sops.secrets.gmail_app_password_lovelainautomations.path;
        in
        ''
          # Himalaya email client configuration
          # Multi-account Gmail setup for OpenCode + Hermes shared pipeline
          # Format: himalaya v1.2.0
          #
          # Passwords are managed via SOPS secrets — /run/secrets/ equivalents
          # deployed by sops-nix home-manager module.

          # ==============================================================================
          # Account: wrighterik77 (default)
          # ==============================================================================
          [accounts.wrighterik77]
          email = "wrighterik77@gmail.com"
          default = true

          backend.type = "imap"
          backend.host = "imap.gmail.com"
          backend.port = 993
          backend.encryption.type = "tls"
          backend.login = "wrighterik77@gmail.com"
          backend.auth.type = "password"
          backend.auth.cmd = "cat ${wrighterik77Pass}"

          message.send.backend.type = "smtp"
          message.send.backend.host = "smtp.gmail.com"
          message.send.backend.port = 465
          message.send.backend.encryption.type = "tls"
          message.send.backend.login = "wrighterik77@gmail.com"
          message.send.backend.auth.type = "password"
          message.send.backend.auth.cmd = "cat ${wrighterik77Pass}"

          # ==============================================================================
          # Account: lovelainautomations
          # ==============================================================================
          [accounts.lovelainautomations]
          email = "lovelainautomations@gmail.com"

          backend.type = "imap"
          backend.host = "imap.gmail.com"
          backend.port = 993
          backend.encryption.type = "tls"
          backend.login = "lovelainautomations@gmail.com"
          backend.auth.type = "password"
          backend.auth.cmd = "cat ${lovelainautomationsPass}"

          message.send.backend.type = "smtp"
          message.send.backend.host = "smtp.gmail.com"
          message.send.backend.port = 465
          message.send.backend.encryption.type = "tls"
          message.send.backend.login = "lovelainautomations@gmail.com"
          message.send.backend.auth.type = "password"
          message.send.backend.auth.cmd = "cat ${lovelainautomationsPass}"
        '';
    };
}
