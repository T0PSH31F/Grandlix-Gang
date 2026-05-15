{
  config,
  lib,
  ...
}:
let
  cfg = config.services.infrastructure.langfuse;
in
{
  options.services.infrastructure.langfuse = {
    enable = lib.mkEnableOption "Langfuse Observability Platform via OCI Container";

    port = lib.mkOption {
      type = lib.types.port;
      default = 3005;
      description = "Port for Langfuse dashboard";
    };

    databaseUrl = lib.mkOption {
      type = lib.types.str;
      default = "postgresql:///langfuse?host=/run/postgresql";
      description = "PostgreSQL DB connection string for Langfuse runtime";
    };

    nextAuthSecret = lib.mkOption {
      type = lib.types.str;
      default = "my-super-secret-next-auth-key-change-me";
      description = "NextAuth secret (use sops in prod)";
    };

    salt = lib.mkOption {
      type = lib.types.str;
      default = "my-super-secret-salt-change-me";
      description = "Salt string (use sops in prod)";
    };
  };

  config = lib.mkIf cfg.enable {
    # Auto-provision the langfuse DB in Postgres
    services.postgresql = {
      ensureDatabases = [ "langfuse" ];
      # Langfuse connects directly to `postgresql` schema without TLS overhead since it's local
    };

    virtualisation.oci-containers.containers.langfuse = {
      image = "ghcr.io/langfuse/langfuse:latest";
      ports = [ "${toString cfg.port}:3000" ];
      environment = {
        PORT = "3000";
        NODE_ENV = "production";
        NEXT_PUBLIC_SIGN_UP_DISABLED = "false";
        DATABASE_URL = cfg.databaseUrl;
        NEXTAUTH_SECRET = cfg.nextAuthSecret;
        SALT = cfg.salt;
      };
      extraOptions = [
        "--network=host" # Access local postgres easily
      ];
    };

    # Open firewall for the local port
    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
