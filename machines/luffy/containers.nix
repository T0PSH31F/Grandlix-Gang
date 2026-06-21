{ ... }:

{
  virtualisation.oci-containers.containers = {

    crawl4ai = {
      image = "unclecode/crawl4ai@sha256:a45fd08f8f15f67026c1bff0a151f0479244caf6751a0c6943b3870efafcd025";
      ports = [ "32775:11235" ];
    };

    skyvern-ui = {
      image = "public.ecr.aws/skyvern/skyvern-ui@sha256:5d963660ec3a0827f79b2e1549e99112d5e707926d623b9423c2cb0d31566cb7";
      ports = [ "32776:8080" ];
    };

    skyvern-api = {
      image = "public.ecr.aws/skyvern/skyvern@sha256:d52b7ddc32301f46de09ed340ab3097b22a2c13e4b3d99b76273a03c92fc7960";
      ports = [ "32779:8000" ];
    };

    skyvern-chrome = {
      image = "ghcr.io/browserless/chromium@sha256:8fb011d07d4f469ea936a0605b4705c7b585108a095d598fcd27b7bef9597caa";
      ports = [ "32780:3000" ];
    };

    sim-studio-ui = {
      image = "ghcr.io/simstudioai/simstudio@sha256:a96bec26e7bca9d125fe6d03e3030082cf97d074fae5b6a0387a44c591e1d1e1";
      ports = [ "32790:3000" ];
    };

    maxkb = {
      image = "1panel/maxkb@sha256:42aad1e002f28c6dd865b6f299297e44029477c1a7a6280c6427e5128b64b5fe";
      ports = [ "32784:8080" ];
      # Shared Postgres handled natively, but keeping data volume intact for other settings
      volumes = [ "/var/lib/maxkb:/var/lib/postgresql/data" ];
    };

    spacedrive = {
      image = "ghcr.io/spacedriveapp/spacedrive/server@sha256:fd3bc896f3a5b8e429e008cedde361d6b9468c48d8c81996fdb1d99e90e0837b";
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
      image = "henrygd/beszel@sha256:a849ad80814b6a1a3be665304dcace5d4854b3bed7bde4dd1227e8ce1b82d477";
      ports = [ "32772:8090" ];
      volumes = [ "/var/lib/beszel:/beszel_data" ];
    };

    # Removed: homepage-dashboard
    # Replaced by the declarative NixOS native service at port 3007.
    # Caddy now reverse-proxies lovelain.duckdns.org → localhost:3007.
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/maxkb 0755 root root -"
    "d /var/lib/spacedrive 0755 root root -"
    "d /var/lib/beszel 0755 root root -"
    # "d /var/lib/homepage 0755 root root -"  # obsolete — replaced by NixOS native service
  ];
}
