{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.ai-services.brain-service;

  # Python environment with all dependencies
  pythonEnv = pkgs.python3.withPackages (
    ps: with ps; [
      # Core API
      fastapi
      uvicorn
      pydantic
      sqlalchemy
      psycopg2
      pgvector

      # LlamaIndex
      llama-index-core
      llama-index-vector-stores-postgres
      llama-index-embeddings-ollama
      llama-index-llms-openai

      # Document parsing
      pymupdf # PDF
      ebooklib # EPUB
      beautifulsoup4 # HTML
      markdown # Markdown → HTML conversion
      lxml # Fast HTML parser
      python-multipart # File uploads

      # File watching
      watchdog

      # MCP server
      mcp
    ]
  );

  # Brain Service Python Script — loaded from external file to avoid Nix heredoc indentation issues
  brainScript = ./brain_server.py;

in
{
  options.services.ai-services.brain-service = {
    enable = lib.mkEnableOption "Brain Service (FastAPI + LlamaIndex + PGVector PKB)";

    port = lib.mkOption {
      type = lib.types.port;
      default = 8010;
      description = "HTTP API port";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Host IP to bind the API server to (set to 127.0.0.1 for local access, 0.0.0.0 for LAN/public access)";
    };

    llmApiBase = lib.mkOption {
      type = lib.types.str;
      default = "https://openrouter.ai/api/v1";
      description = "OpenAI compatible base URL";
    };

    llmModel = lib.mkOption {
      type = lib.types.str;
      default = "gpt-4o-mini";
      description = "LLM model for query answering";
    };

    embedModel = lib.mkOption {
      type = lib.types.str;
      default = "nomic-embed-text";
      description = "Ollama embedding model";
    };

    embedDim = lib.mkOption {
      type = lib.types.int;
      default = 768;
      description = "Embedding dimension (must match model)";
    };

    booksDir = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Directory to watch for new PDF/EPUB files";
    };

    mcpEnable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable MCP server for Hermes";
    };

    apiSecretFile = lib.mkOption {
      type = lib.types.path;
      default = config.clan.core.vars.generators.brain-service.files."env".path;
      description = "Path to the environment file with API keys.";
    };
  };

  config = lib.mkIf cfg.enable {
    clan.core.vars.generators.brain-service = {
      files."env" = {
        secret = true;
        owner = "postgres";
        group = "postgres";
      };
      prompts."api-key" = {
        type = "hidden";
        description = "OpenRouter/OpenAI API key for Brain Service";
      };
      script = ''
        if [ -f "$prompts/api-key" ]; then
          API_KEY=$(cat "$prompts/api-key")
        else
          API_KEY="dummy"
        fi
        echo "LLM_API_KEY=$API_KEY" > "$out/env"
      '';
    };

    # Grant postgres access to traverse /home/t0psh31f/ for PKB books
    users.users.postgres.extraGroups = [ "users" ];

    # Create data directory
    systemd.tmpfiles.rules = [
      "d /var/lib/brain-service 0750 postgres postgres -"
      "d /var/lib/brain-service/tiktoken-cache 0755 postgres postgres -"
    ];

    # Main API service
    systemd.services.brain-service = {
      description = "Brain Service PKB API";
      wantedBy = [ "multi-user.target" ];
      after = [
        "postgresql.service"
        "postgresql-extensions.service"
        "ollama.service"
      ];
      requires = [ "postgresql.service" ];

      environment = {
        DB_NAME = "vectordb";
        DB_USER = "postgres";
        DB_HOST = "127.0.0.1";
        DB_PORT = "5432";
        LLM_API_BASE = cfg.llmApiBase;
        LLM_MODEL = cfg.llmModel;
        OLLAMA_URL = "http://127.0.0.1:11434";
        EMBED_MODEL = cfg.embedModel;
        EMBED_DIM = toString cfg.embedDim;
        PORT = toString cfg.port;
        HOST = cfg.host;
        BRAIN_MODE = "api";
        MANIFEST_PATH = "/var/lib/brain-service/manifest.json";
        TIKTOKEN_CACHE_DIR = "/var/lib/brain-service/tiktoken-cache";
      }
      // lib.optionalAttrs (cfg.booksDir != null) {
        BOOKS_DIR = cfg.booksDir;
      };

      serviceConfig = {
        ExecStart = "${pythonEnv}/bin/python ${brainScript}";
        Restart = "on-failure";
        User = "postgres";
        EnvironmentFile = cfg.apiSecretFile;
      };
    };

    # MCP server for Hermes (runs on-demand via stdin/stdout)
    systemd.services.brain-mcp = lib.mkIf cfg.mcpEnable {
      description = "Brain Service MCP Server";
      # Triggered on-demand by Hermes, not at boot
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pythonEnv}/bin/python ${brainScript}";
        User = "postgres";
        EnvironmentFile = cfg.apiSecretFile;
        Environment = [
          "BRAIN_MODE=mcp"
          "DB_NAME=vectordb"
          "DB_USER=postgres"
          "DB_HOST=127.0.0.1"
          "DB_PORT=5432"
          "OLLAMA_URL=http://127.0.0.1:11434"
          "EMBED_MODEL=${cfg.embedModel}"
          "EMBED_DIM=${toString cfg.embedDim}"
          "MANIFEST_PATH=/var/lib/brain-service/manifest.json"
          "TIKTOKEN_CACHE_DIR=/var/lib/brain-service/tiktoken-cache"
        ];
      };
    };

    # File watcher service (optional)
    systemd.services.brain-watcher = lib.mkIf (cfg.booksDir != null) {
      description = "Brain Service File Watcher";
      wantedBy = [ "multi-user.target" ];
      after = [ "brain-service.service" ];
      requires = [ "brain-service.service" ];

      environment = {
        BRAIN_MODE = "watcher";
        DB_NAME = "vectordb";
        DB_USER = "postgres";
        DB_HOST = "127.0.0.1";
        DB_PORT = "5432";
        OLLAMA_URL = "http://127.0.0.1:11434";
        EMBED_MODEL = cfg.embedModel;
        EMBED_DIM = toString cfg.embedDim;
        BOOKS_DIR = cfg.booksDir;
        MANIFEST_PATH = "/var/lib/brain-service/manifest.json";
        TIKTOKEN_CACHE_DIR = "/var/lib/brain-service/tiktoken-cache";
      };

      serviceConfig = {
        ExecStart = "${pythonEnv}/bin/python ${brainScript}";
        Restart = "on-failure";
        User = "postgres";
        EnvironmentFile = cfg.apiSecretFile;
      };
    };

    # MCP wrapper package for Hermes integration
    environment.systemPackages = lib.mkIf cfg.mcpEnable [
      (pkgs.writeShellScriptBin "brain-mcp" ''
        export BRAIN_MODE=mcp
        export DB_NAME=vectordb
        export DB_USER=postgres
        export DB_HOST=127.0.0.1
        export DB_PORT=5432
        export OLLAMA_URL=http://127.0.0.1:11434
        export EMBED_MODEL=${cfg.embedModel}
        export EMBED_DIM=${toString cfg.embedDim}
        export MANIFEST_PATH=/var/lib/brain-service/manifest.json
        export TIKTOKEN_CACHE_DIR=/var/lib/brain-service/tiktoken-cache

        exec ${pythonEnv}/bin/python ${brainScript}
      '')
      # CLI tool for quick ingestion
      (pkgs.writeShellScriptBin "brain-ingest" ''
        if [ -z "$1" ]; then
          echo "Usage: brain-ingest <file-or-directory>"
          echo "  Supports: PDF, EPUB, HTML, MD, TXT"
          exit 1
        fi

        if [ -d "$1" ]; then
          curl -s -X POST "http://127.0.0.1:8010/ingest/directory?directory=$1" | jq .
        else
          curl -s -X POST "http://127.0.0.1:8010/ingest/path?path=$1" | jq .
        fi
      '')
      # CLI tool for ingesting websites
      (pkgs.writeShellScriptBin "insite" ''
        if [ -z "$1" ]; then
          echo "Usage: insite <url>"
          echo "  Downloads a website and ingests it into your PKB"
          echo ""
          echo "Examples:"
          echo "  insite docs.clan.lol"
          echo "  insite https://nixos.wiki/wiki/NixOS_Wiki"
          echo "  insite https://blog.example.com/article"
          exit 1
        fi

        # Normalize URL
        URL="$1"
        if [[ ! "$URL" =~ ^https?:// ]]; then
          URL="https://$URL"
        fi

        # Extract domain for folder name
        DOMAIN=$(echo "$URL" | sed -E 's|https?://([^/]+).*|\1|' | sed 's|www\.||')
        DEST="$HOME/Notes/PKB/websites/$DOMAIN"

        echo "Downloading $URL → $DEST/"
        mkdir -p "$DEST"

        ${pkgs.wget}/bin/wget --mirror --convert-links --adjust-extension --page-requisites \
          --no-parent --no-host-directories --directory-prefix="$DEST" \
          --reject="*.css,*.js,*.png,*.jpg,*.jpeg,*.gif,*.svg,*.ico,*.woff,*.woff2,*.ttf,*.eot" \
          --timeout=10 --tries=2 "$URL" 2>&1 | tail -5

        echo ""
        echo "Ingesting into Brain Service..."
        RESULT=$(curl -s -X POST "http://127.0.0.1:8010/ingest/directory?directory=$DEST" 2>&1)
        FILES=$(echo "$RESULT" | ${pkgs.jq}/bin/jq -r '.files // 0')
        echo "Done! Ingested $FILES files from $DOMAIN"
        echo "  Source: $DEST/"
      '')

      # CLI tool for querying
      (pkgs.writeShellScriptBin "brain-query" ''
        if [ -z "$1" ]; then
          echo "Usage: brain-query <question>"
          exit 1
        fi

        curl -s -X POST http://127.0.0.1:8010/query \
          -H "Content-Type: application/json" \
          -d "{\"question\": \"$1\"}" | jq .
      '')
    ];

    # Impermanence
    environment.persistence."/persist" =
      lib.mkIf (config.layers.layer-10.system.config.impermanence.enable or false)
        {
          directories = [
            {
              directory = "/var/lib/brain-service";
              user = "postgres";
              group = "postgres";
              mode = "0750";
            }
          ];
        };
  };
}
