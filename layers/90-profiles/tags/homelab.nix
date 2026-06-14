{ lib, ... }:
{
  services = {
    searxng.enable = lib.mkDefault true;
    home-assistant-server.enable = lib.mkDefault true;
    headscale-server.enable = lib.mkDefault true;
    vaultwarden-server.enable = lib.mkDefault true;
    filebrowser-app.enable = lib.mkDefault true;
    glances-server.enable = lib.mkDefault true;
  };
}
