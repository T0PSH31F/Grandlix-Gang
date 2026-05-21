{ ... }:

{
  virtualisation.oci-containers.containers = {

    crawl4ai = {
      image = "crawl4ai/crawl4ai:latest";
      ports = [ "32775:11235" ];
    };

    skyvern-ui = {
      image = "ghcr.io/skyvern-ai/skyvern-ui:latest";
      ports = [ "32776:8080" ];
    };

    skyvern-api = {
      image = "ghcr.io/skyvern-ai/skyvern:latest";
      ports = [ "32779:8000" ];
    };

    skyvern-chrome = {
      image = "ghcr.io/skyvern-ai/chrome:latest";
      ports = [ "32780:9222" ];
    };

    sim-studio-ui = {
      image = "simstudio/ui:latest"; # Replace with precise tag if needed
      ports = [ "32790:3000" ];
    };

    sim-studio-realtime = {
      image = "simstudio/realtime:latest"; # Replace with precise tag if needed
      ports = [ "32789:8080" ];
    };

    maxkb = {
      image = "1panel/maxkb:latest";
      ports = [ "32784:8080" ];
      # Shared Postgres handled natively, but keeping data volume intact for other settings
      volumes = [ "/var/lib/maxkb:/var/lib/postgresql/data" ];
    };

    openclaw = {
      image = "openclaw/openclaw:latest"; # Replace with precise tag if needed
      ports = [ "59879:8080" ];
    };

    spacedrive = {
      image = "spacedrive/server:latest";
      ports = [
        "32768:7373"
        "32769:8080"
      ];
      volumes = [ "/var/lib/spacedrive:/data" ];
    };

    beszel-hub = {
      image = "henrygd/beszel:latest";
      ports = [ "32772:8090" ];
      volumes = [ "/var/lib/beszel:/beszel_data" ];
    };

    homepage-dashboard = {
      image = "ghcr.io/gethomepage/homepage:latest";
      ports = [ "3000:3000" ];
      volumes = [
        "/var/lib/homepage:/app/config"
        "/var/run/docker.sock:/var/run/docker.sock:ro"
      ];
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/maxkb 0755 root root -"
    "d /var/lib/spacedrive 0755 root root -"
    "d /var/lib/beszel 0755 root root -"
    "d /var/lib/homepage 0755 root root -"
  ];
}
