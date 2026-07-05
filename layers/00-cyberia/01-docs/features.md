# NFP Feature Overview

> High-level summary of all major features managed by this flake.

## Desktop — Noctalia v5 + Hyprland

Material You theming from wallpaper via Noctalia v5 (native C++/OpenGL ES shell):
- Dynamic GTK/QT/Terminal/Hyprland colors via Noctalia templates
- Saber-like glowing borders, deep shadows
- Vicinae launcher, Hyprspace workspace overview
- Neovim inherits Noctalia colors at startup
- **Docs**: https://docs.noctalia.dev/v5/

## Editor — NixVim (Replaces Helix)

- **Navigation**: h/j/k/l home row, Flash character jumps
- **File management**: Neo-tree sidebar, Yazi in-editor, Telescope fuzzy find
- **Completion**: blink.cmp (Rust backend) + LuaSnip snippets
- **LSP**: 15 servers (nixd, ts_ls, rust-analyzer, gopls, lua_ls, etc.)
- **Git**: LazyGit + gitsigns gutter blame
- **AI**: OpenCode (Claude Code) + Ollama (local LLMs)
- **Effects**: Smooth scrolling (neoscroll) + smear cursor trail
- **Multi-cursor**: VS Code-style Ctrl+Shift+Up/Down
- **Theme**: Noctalia Material You with tokyo-night fallback

**Details**: [yazelix_guide.md](yazelix_guide.md)

## CLI/TUI Environment

| Tool | Purpose |
|------|---------|
| Zellij | Terminal multiplexer with 4 layout profiles |
| Yazi | Terminal file manager |
| Atuin | Shell history with search |
| Fzf | Fuzzy find for shell |
| Zoxide | Smart directory jumping |
| Starship | Shell prompt |
| Kitty | GPU-accelerated terminal |

**Layout profiles**: `z-dev` (dev split), `z-git`, `z-server`, `compact`

## AI Stack

| Component | Role |
|-----------|------|
| **Hermes Agent** | Self-improving AI gateway (16 personalities, multi-provider) |
| **Ollama** | Local LLM inference (llama3.2, etc.) |
| **OpenCode** | Claude Code in-editor AI assistant |
| **Open WebUI** | Chat interface at `chat.lovelain.duckdns.org` |
| **SillyTavern** | AI roleplay at `silly.lovelain.duckdns.org` |
| **n8n** | Workflow automation at `n8n.lovelain.duckdns.org` |
| **MCP Servers** | Filesystem, GitHub, browser-use, sequential-thinking |

## Self-Hosted Services

| Service | Machine | Port |
|---------|---------|------|
| AdGuard Home | Luffy | 3002 |
| Nextcloud | Luffy | 8080 |
| Immich | Luffy | 2283 |
| Vaultwarden | Luffy | 8222 |
| Jellyfin | Z0r0 | 8096 |
| Sonarr / Radarr / Prowlarr | Z0r0 | 8989/7878/9696 |

## Security

- **SOPS-nix**: All secrets encrypted at rest (Age), decrypted at build time
- **Impermanence**: Root wiped every boot — persistent state opt-in via `/persist`
- **Headscale**: Tailscale-compatible mesh VPN
- **ZeroTier**: Alternative overlay network

## System Architecture

- **NixOS 26.05** (Yarara) with nixpkgs-unstable
- **Clan-Core** fleet management framework
- **Flake-parts** modular configuration
- **Linux Zen** kernel on z0r0
- **Impermanence** with Btrfs rollback on every boot

**Details**: Profile-Architecture.md

## Machines

| Machine | Role | Tags |
|---------|------|------|
| **Z0r0** (LG Gram 17) | Laptop, media server, AI dev | laptop, workstation, ai-server, homelab, media-server, cache-server |
| **Luffy** (Custom Desktop) | Primary workstation, homelab | desktop, workstation, ai-server, homelab |
