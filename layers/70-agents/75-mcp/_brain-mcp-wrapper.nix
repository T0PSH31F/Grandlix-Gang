{
  pkgs,
  brainScript,
  pythonEnv,
  cfg ? {
    dbName = "brain_db";
    dbUser = "postgres";
    dbHost = "127.0.0.1";
    dbPort = 5432;
    llmProvider = "ollama";
    llmApiBase = "https://openrouter.ai/api/v1";
    llmModel = "gpt-4o-mini";
    embedModel = "nomic-embed-text";
    embedDim = 768;
  },
}:

pkgs.writeShellScriptBin "brain-mcp" ''
  export BRAIN_MODE=mcp
  export DB_NAME=${cfg.dbName}
  export DB_USER=${cfg.dbUser}
  export DB_HOST=${cfg.dbHost}
  export DB_PORT=${toString cfg.dbPort}
  export LLM_PROVIDER=${cfg.llmProvider}
  export LLM_API_BASE=${cfg.llmApiBase}
  export LLM_MODEL=${cfg.llmModel}
  export OLLAMA_URL=http://127.0.0.1:11434
  export EMBED_MODEL=${cfg.embedModel}
  export EMBED_DIM=${toString cfg.embedDim}
  export MANIFEST_PATH=/var/lib/brain-service/manifest.json
  export TIKTOKEN_CACHE_DIR=/var/lib/brain-service/tiktoken-cache

  exec ${pythonEnv}/bin/python ${brainScript}
''
