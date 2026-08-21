{ pkgs, brainScript, pythonEnv }:

pkgs.writeShellScriptBin "brain-mcp" ''
  export BRAIN_MODE=mcp
  export DB_NAME=vectordb
  export DB_USER=postgres
  export DB_HOST=127.0.0.1
  export DB_PORT=5432
  export OLLAMA_URL=http://127.0.0.1:11434
  export EMBED_MODEL=nomic-embed-text
  export EMBED_DIM=768
  export MANIFEST_PATH=/var/lib/brain-service/manifest.json

  exec ${pythonEnv}/bin/python ${brainScript}
''
