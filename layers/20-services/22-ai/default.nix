# flake-parts/services/ai/default.nix
# AI and LLM services
{
  imports = [
    ./ai-services.nix           # Master switch for sub-services
    ./ai-packages.nix           # AI system packages
    ./postgresql-vectordb.nix   # PostgreSQL + pgvector
    ./open-webui.nix            # Open WebUI frontend
    ./qdrant.nix                # Qdrant vector database
    ./chromadb.nix              # ChromaDB vector database
    ./localai.nix               # LocalAI OCI container
    ./ollama.nix                # Ollama local LLM server
    ./ollama-ui.nix             # NextJS Ollama UI
    ./lmstudio.nix              # LM Studio desktop app
    ./jan.nix                   # Jan AI desktop app
    ./cherry-studio.nix         # Cherry Studio desktop app
    ./aider.nix                 # Aider AI pair programming
    ./context-forge.nix          # ContextForge MCP gateway
    ./brain-service.nix          # FastAPI + LlamaIndex + PGVector RAG
    ./llm-agents.nix            # LLM coding agent packages
    ./sillytavern.nix           # SillyTavern AI chat frontend
    ./voice.nix                 # Whisper STT + Piper TTS
    ./wyoming.nix               # Wyoming protocol services
    ./llama-cpp.nix             # llama.cpp server
    ./litellm.nix               # LiteLLM proxy
    ./llama-swap.nix            # llama-swap router
    ./vllm.nix                  # vLLM inference server
  ];
}
