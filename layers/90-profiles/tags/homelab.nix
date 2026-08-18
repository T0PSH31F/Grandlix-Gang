{ config, lib, ... }:
{
  services = {
    searxng.enable = lib.mkDefault true;
    home-assistant-server.enable = lib.mkDefault true;
    headscale-server.enable = lib.mkDefault true;
    vaultwarden-server.enable = lib.mkDefault true;
    filebrowser-app.enable = lib.mkDefault true;
    glances-server.enable = lib.mkDefault true;
    n8n-server.enable = lib.mkDefault true;

    honcho = {
      enable = lib.mkDefault true;
      port = lib.mkDefault 8000;
    };

    alertmanager-ntfy = {
      enable = lib.mkDefault true;
      ntfyUrl = lib.mkDefault "http://localhost:8099";
      ntfyTopic = lib.mkDefault "prometheus-alerts";
    };

    postgresql = {
      enableTCPIP = lib.mkDefault true;
    };

    mautrix-bridges = {
      enable = lib.mkDefault true;
      homeserverUrl = lib.mkDefault "http://localhost:8008";
      homeserverDomain = lib.mkDefault "matrix.local";
      whatsapp.enable = lib.mkDefault true;
      signal.enable = lib.mkDefault true;
    };
  };

  layers.layer-20.services.config = {
    ntfy-sh = {
      enable = lib.mkDefault true;
      port = lib.mkDefault 8099;
    };
  };
}
