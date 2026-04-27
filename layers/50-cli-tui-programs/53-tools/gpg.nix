{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.features.cli;
in
{
  home = lib.mkIf cfg.enable {
    programs.gpg.enable = true;
    services.gpg-agent = {
      enable = true;
      pinentry.package = pkgs.pinentry-gnome3;
      enableSshSupport = false;
    };
  };
}
