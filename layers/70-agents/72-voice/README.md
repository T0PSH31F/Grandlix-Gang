# Tier 72 — Voice (`72-voice`)

## Tier Purpose

The `72-voice` tier is responsible for local speech-to-text (STT / ASR), text-to-speech (TTS), wake-word detection, and Wyoming protocol integration. It houses voice engine services such as Whisper (faster-whisper, whisper.cpp), Piper TTS, OpenWakeWord, and XTTSv2. Text-only agents, LLM routers, memory vaults, and generic media playback do NOT belong here.

## Module Registry

| Module | Description | Option Path | Default Port(s) | Service Type | Enabling Tag(s) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `voice.nix` | Unified local STT (whisper.cpp) and TTS (Piper/XTTSv2) service stack. | `layers.layer-72.voice.voice` | 8097 (STT), 8098 (TTS) | Always-on systemd service | `ai-agent`, `homelab`, `desktop` |
| `wyoming.nix` | Wyoming protocol satellite & server stack (piper, faster-whisper, openwakeword). | `services.wyoming-services` | 10200 (Piper), 10300 (Whisper), 10400 (WakeWord) | Always-on systemd service | `ai-agent`, `homelab` |
| `asr-tts/agent-audio.nix` | Home-Manager package collection for CLI audio tooling and voice engines. | `layers.layer-70.agent.asr-tts` | None | On-demand package bundle | `ai-agent`, `desktop` |

## Tier Relationships

- **Consumable by Harness & Orchestrators**: Used by voice-enabled agent harnesses in `71-harness` (e.g., `hermes-live-voice.nix`) and Home Assistant / smart home services in `20-services`.
- **Hardware Integration**: Relies on system-level audio devices and drivers configured in `10-system` (`18-peripherals/audio.nix`, PipeWire/ALSA).
