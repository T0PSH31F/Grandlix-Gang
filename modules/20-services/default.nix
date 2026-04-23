{ ... }:
{
  imports = [
    ./21-networking/adguard.nix
    ./21-networking/avahi.nix
    ./21-networking/caddy.nix
    ./25-data/filebrowser.nix
    ./26-monitoring/glances.nix
    ./25-data/harmonia.nix
    ./21-networking/headscale.nix
    ./27-automation/home-assistant.nix
    ./26-monitoring/homepage-dashboard.nix
    ./25-data/langfuse.nix
    ./26-monitoring/monitoring.nix
    ./27-automation/n8n.nix
    ./25-data/nextcloud.nix
    ./27-automation/pastebin.nix
    ./27-automation/searxng.nix
    ./21-networking/ssh-agent.nix
    ./21-networking/tailscale.nix
    ./25-data/databases.nix
    ./25-data/vaultwarden.nix
  ];
}
