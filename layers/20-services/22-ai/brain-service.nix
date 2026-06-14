{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.ai-services.brain-service;

  # Creating a Python environment with FastAPI and LlamaIndex
  pythonEnv = pkgs.python3.withPackages (
    ps: with ps; [
      fastapi
      uvicorn
      pydantic
      sqlalchemy
      psycopg2
      pgvector
      llama-index-core
      llama-index-vector-stores-postgres
      llama-index-llms-openai # For OpenRouter compatibility
    ]
  );

  # Brain Service Python Script
  brainScript = pkgs.writeText "brain_server.py" ''
    import os
    import uvicorn
    from fastapi import FastAPI, HTTPException
    from pydantic import BaseModel
    from typing import Optional, List, Dict, Any

    from llama_index.core import VectorStoreIndex, Document
    from llama_index.vector_stores.postgres import PGVectorStore
    from llama_index.core import StorageContext
    from llama_index.llms.openai import OpenAI
    from llama_index.core import Settings

    app = FastAPI(title="Brain Service PKB", description="Local Knowledge Base API")

    # Configuration
    DB_NAME = os.getenv("DB_NAME", "vectordb")
    DB_USER = os.getenv("DB_USER", "postgres")
    DB_PASS = os.getenv("DB_PASS", "")
    DB_HOST = os.getenv("DB_HOST", "127.0.0.1")
    DB_PORT = os.getenv("DB_PORT", "5432")
    LLM_API_KEY = os.getenv("LLM_API_KEY", "dummy")
    LLM_API_BASE = os.getenv("LLM_API_BASE", "https://openrouter.ai/api/v1")
    LLM_MODEL = os.getenv("LLM_MODEL", "openai/gpt-4o-mini")

    # Init LlamaIndex Settings
    Settings.llm = OpenAI(
        api_key=LLM_API_KEY, 
        api_base=LLM_API_BASE, 
        model=LLM_MODEL
    )

    def get_index():
        vector_store = PGVectorStore.from_params(
            database=DB_NAME,
            host=DB_HOST,
            password=DB_PASS,
            port=DB_PORT,
            user=DB_USER,
            table_name="pkb_documents",
            embed_dim=1536
        )
        storage_context = StorageContext.from_defaults(vector_store=vector_store)
        return VectorStoreIndex.from_vector_store(vector_store, storage_context=storage_context)

    class RememberRequest(BaseModel):
        text: str
        source: Optional[str] = None
        user: Optional[str] = None
        project: Optional[str] = None
        tags: Optional[List[str]] = None

    class QueryRequest(BaseModel):
        question: str
        scope: Optional[str] = None
        user: Optional[str] = None

    @app.post("/remember")
    async def remember(req: RememberRequest):
        try:
            metadata = {
                "source": req.source or "unknown",
                "user": req.user or "system",
                "project": req.project or "general",
                "tags": ",".join(req.tags) if req.tags else ""
            }
            doc = Document(text=req.text, metadata=metadata)
            index = get_index()
            index.insert(doc)
            return {"status": "success", "message": "Information ingested into Brain."}
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))

    @app.post("/query")
    async def query(req: QueryRequest):
        try:
            index = get_index()
            # Basic query engine
            # In LlamaIndex, we should use a retriever with filters for scope/user later.
            query_engine = index.as_query_engine()
            response = query_engine.query(req.question)
            
            sources = []
            for node in response.source_nodes:
                sources.append({
                    "text": node.text,
                    "score": node.score,
                    "metadata": node.metadata
                })
                
            return {
                "answer": str(response),
                "sources": sources
            }
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))

    @app.get("/health")
    async def health():
        return {"status": "healthy"}

    if __name__ == "__main__":
        import os
        port = int(os.getenv("PORT", "8010"))
        uvicorn.run(app, host="0.0.0.0", port=port)
  '';

in
{
  options.services.ai-services.brain-service = {
    enable = lib.mkEnableOption "Brain Service (FastAPI + LlamaIndex + PGVector PKB)";

    port = lib.mkOption {
      type = lib.types.port;
      default = 8010;
      description = "Port to listen on";
    };

    llmApiBase = lib.mkOption {
      type = lib.types.str;
      default = "https://openrouter.ai/api/v1";
      description = "OpenAI compatible base URL (e.g. OpenRouter, LocalAI)";
    };

    llmModel = lib.mkOption {
      type = lib.types.str;
      default = "openai/gpt-4o-mini";
      description = "Model to use for LLM Generation";
    };

    apiSecretFile = lib.mkOption {
      type = lib.types.path;
      default = config.clan.core.vars.generators.brain-service.files."env".path;
      description = "Path to the environment file containing the LLM API key.";
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

    systemd.services.brain-service = {
      description = "Brain Service PKB API";
      wantedBy = [ "multi-user.target" ];
      after = [
        "postgresql.service"
        "postgresql-extensions.service"
      ];
      requires = [ "postgresql.service" ];

      environment = {
        DB_NAME = "vectordb";
        DB_USER = "postgres";
        DB_HOST = "127.0.0.1";
        DB_PORT = "5432";
        LLM_API_BASE = cfg.llmApiBase;
        LLM_MODEL = cfg.llmModel;
        PORT = toString cfg.port;
      };

      serviceConfig = {
        ExecStart = "${pythonEnv}/bin/python ${brainScript}";
        Restart = "on-failure";
        User = "postgres"; # Run as postgres to avoid local socket auth issues unless properly mapped
        EnvironmentFile = cfg.apiSecretFile;
      };
    };
  };
}
