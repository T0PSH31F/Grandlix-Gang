{ ... }:

{
  virtualisation.oci-containers.containers = {

    crawl4ai = {
      image = "unclecode/crawl4ai:latest";
      ports = [ "32775:11235" ];
    };

    skyvern-ui = {
      image = "public.ecr.aws/skyvern/skyvern-ui:latest";
      ports = [ "32776:8080" ];
    };

    skyvern-api = {
      image = "public.ecr.aws/skyvern/skyvern:latest";
      ports = [ "32779:8000" ];
    };

    skyvern-chrome = {
      image = "ghcr.io/browserless/chromium:latest";
      ports = [ "32780:3000" ];
    };

    sim-studio-ui = {
      image = "ghcr.io/simstudioai/simstudio:latest";
      ports = [ "32790:3000" ];
    };

    sim-studio-realtime = {
      image = "ghcr.io/simstudioai/realtime:latest";
      ports = [ "32789:8080" ];
    };

    maxkb = {
      image = "1panel/maxkb:latest";
      ports = [ "32784:8080" ];
      # Shared Postgres handled natively, but keeping data volume intact for other settings
      volumes = [ "/var/lib/maxkb:/var/lib/postgresql/data" ];
    };

    openclaw = {
      image = "ghcr.io/openclaw/openclaw:latest";
      ports = [ "59879:8080" ];
    };

    spacedrive = {
      image = "ghcr.io/spacedriveapp/spacedrive/server:latest";
      ports = [
        "32768:7373"
        "32769:8080"
      ];
      volumes = [ "/var/lib/spacedrive:/data" ];
      environment = {
        SD_AUTH = "disabled";
      };
    };

    beszel-hub = {
      image = "henrygd/beszel:latest";
      ports = [ "32772:8090" ];
      volumes = [ "/var/lib/beszel:/beszel_data" ];
    };

    homepage-dashboard = {
      image = "ghcr.io/gethomepage/homepage:latest";
      # Limit network exposure to localhost since public access is proxied securely via Caddy
      ports = [ "127.0.0.1:3006:3000" ];
      volumes = [
        "/var/lib/homepage:/app/config"
        # SECURITY NOTE: Exposing the host's Podman/Docker socket allows container escaping.
        # Homepage only uses this for the optional container status widget. 
        # Since it is not actively required/used in our configurations, we disable it.
        # If needed in the future, prefer using a secure API proxy (e.g. docker-socket-proxy)
        # to restrict socket queries to read-only container status endpoints.
        # "/run/podman/podman.sock:/var/run/docker.sock:ro"
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
