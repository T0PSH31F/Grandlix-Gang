# Tier 74 — AI Infrastructure (`74-ai-infra`)

## Tier Purpose

The `74-ai-infra` tier is responsible for local model execution runtimes, GPU inference servers, model swapping proxies, and code execution sandbox environments. It houses low-level model engines such as Ollama, llama.cpp, vLLM, LocalAI, llama-swap, and agent execution sandboxes. Client agent CLIs/IDEs (71-harness), LLM routers/gateways (78-llm-routers), and memory/knowledge bases (73-memory) do NOT belong here.

## Module Registry

| Module | Description | Option Path | Default Port(s) | Service Type | Enabling Tag(s) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `agent-sandbox.nix` | Isolated container sandbox for secure agent code evaluation. | `layers.layer-70.agent.sandbox` | None | On-demand container runner | `ai-agent`, `ai-server` |
| `llama-cpp.nix` | High-performance C/C++ GGUF LLM inference server (`llama-server`). | `services.llama-cpp-server` | 8080 | Always-on systemd service | `gpu-compute`, `ai-server` |
| `llama-swap.nix` | Dynamic model swapper proxy — unloads/loads GGUF models on demand. | `services.llama-swap-proxy` | 8082 | Always-on systemd service | `gpu-compute`, `ai-server` |
| `localai.nix` | Multi-modal local AI server supporting audio, vision, and text models. | `services.ai-services.localai` | 8080 | Always-on OCI container service | `ai-server` |
| `ollama.nix` | Ollama local LLM inference manager supporting GGUF model libraries. | `services.ai-services.ollama` | 11434 | Always-on systemd service | `gpu-compute`, `ai-server` |
| `vllm.nix` | High-throughput distributed GPU inference engine for vLLM models. | `services.vllm-server` | 8000 | Always-on systemd service | `gpu-compute`, `ai-server` |

## Tier Relationships

- **Backend Provider to Routers**: `74-ai-infra` inference endpoints (Ollama `:11434`, llama.cpp `:8080`, vLLM `:8000`) sit behind routers in `78-llm-routers` (Kong Gateway, ExtremeRouter, LiteLLM).
- **GPU Hardware Integration**: Backed by GPU drivers and ROCm/CUDA capabilities defined in `10-system` (`12-hardware/gpu.nix`).
