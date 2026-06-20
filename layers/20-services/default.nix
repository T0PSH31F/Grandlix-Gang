{ ... }:
{
  imports = [
    ./21-networking
    ./22-ai
    ./23-media
    ./24-communication

    ./25-data/databases.nix
    ./25-data/filebrowser.nix
    ./25-data/harmonia.nix
    ./25-data/langfuse.nix
    ./25-data/vaultwarden.nix

    ./26-monitoring/glances.nix
    ./26-monitoring/homepage-dashboard.nix
    ./26-monitoring/monitoring.nix

    ./27-automation/home-assistant.nix
    ./27-automation/n8n.nix
    ./27-automation/pastebin.nix
    ./27-automation/searxng.nix
    ./29-ci
  ];
}
