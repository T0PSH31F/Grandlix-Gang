# ☠️ Nix Flake Pirates (NFP) Configuration

<p align="center">
  <img src="assets/character.gif" alt="One Piece Theme" width="200">
</p>

<h1 align="center">Nix Flake Pirates (NFP)</h1>

<p align="center">
  <a href="https://nixos.org">
    <img src="https://img.shields.io/badge/NixOS-Unstable-blue.svg?style=for-the-badge&logo=nixos&logoColor=white" alt="NixOS">
  </a>
  <a href="https://docs.clan.lol">
    <img src="https://img.shields.io/badge/Clan-Core-orange.svg?style=for-the-badge&logo=rust&logoColor=white" alt="Clan-Core">
  </a>
  <a href="https://github.com/hyprwm/Hyprland">
    <img src="https://img.shields.io/badge/Hyprland-Wayland-9cf.svg?style=for-the-badge&logo=hyprland&logoColor=white" alt="Hyprland">
  </a>
  <a href="https://github.com/Mic92/sops-nix">
    <img src="https://img.shields.io/badge/Sops-Encrypted-green.svg?style=for-the-badge&logo=lock&logoColor=white" alt="Sops-Nix">
  </a>
</p>

> **"Wealth, fame, power. Gold Roger, the King of the Pirates, attained this and everything else the world had to offer."**

Welcome to the **Nix Flake Pirates (NFP)** NixOS configuration repository. This system is a highly modular, declarative, and reproducible infrastructure based on **Clan-Core**, designed for high-performance creative workflows, AI development, and secure operations.

---

## 🏴‍☠️ The Grand Line Fleet

| Character | Machine | Role | Specs & Tags | State |
| :---: | :---: | :---: | :---: | :---: |
| <img src="assets/machines/zoro.png" width="100"> | **Z0r0** | Media & Build Server | **CPU**: Ryzen 9<br>**RAM**: 64GB<br>**Tags**: Media-Server, AI-Server, Build-Server | 🟢 Active |
| <img src="assets/machines/luffy.png" width="100"> | **Luffy** | Primary Workstation & AI | **CPU**: Intel i7-9700F<br>**RAM**: 24GB<br>**Tags**: Workstation, Desktop, AI-Server, Homelab | 🟢 Active |

---

## 🗺️ Fleet Services & Navigation

| Service | Machine | Port | Public URL | Role |
| :--- | :--- | :--- | :--- | :--- |
| **n8n** | Luffy | 5678 | `n8n.lovelain.duckdns.org` | Workflow Automation |
| **Open WebUI** | Luffy | 3004 | `chat.lovelain.duckdns.org` | AI Chat Interface |
| **Ollama** | Luffy | 11434 | `ollama.lovelain.duckdns.org` | AI Model Backend |
| **Nextcloud** | Luffy | 8080 | `nextcloud.lovelain.duckdns.org` | Cloud Storage & Files |
| **Immich** | Luffy | 2283 | `immich.lovelain.duckdns.org` | Photo Management |
| **Vaultwarden** | Luffy | 8222 | `vault.lovelain.duckdns.org` | Password Manager |
| **Komga** | Luffy | 25600 | `komga.lovelain.duckdns.org` | Comics/Manga Library |
| **Your Spotify** | Luffy | 3457 | `spotify.lovelain.duckdns.org` | Listening Analytics |
| **AdGuard Home** | Luffy | 3002 | `adguard.lovelain.duckdns.org` | DNS & Ad-Blocking |
| **Jellyfin** | Z0r0 | 8096 | `jellyfin.lovelain.duckdns.org` | Media Streaming |
| **Sonarr** | Z0r0 | 8989 | `sonarr.lovelain.duckdns.org` | TV Show Management |
| **Radarr** | Z0r0 | 7878 | `radarr.lovelain.duckdns.org` | Movie Management |
| **Prowlarr** | Z0r0 | 9696 | `prowlarr.lovelain.duckdns.org` | Indexer Manager |
| **SillyTavern** | Luffy | 8000 | `silly.lovelain.duckdns.org` | AI Roleplay Interface |

---

## ⚔️ The Arsenal (Features)

### 🖥️ Desktop Experience (Noctalia)
A heavily customized **Hyprland** environment driven by **Matugen** for dynamic material theming.

*   **Neon Aesthetics**: Saber-like glowing borders and deep, rich shadows powered by Hyprland's `col.active_border` and `decoration.shadow`.
*   **Matugen Integration**: Wallpaper-based color schemes that propagate to GTK, QT, Terminals, and Hyprland instantly.
*   **Workflow Optimization**: 
    *   **Vicinae** & **Noctalia** launchers for instant access.
    *   **Hyprspace** overview for workspace management.
    *   **Yazelix**: A custom Helix-based modal editing environment.

### � Brain Force (AI Stack)
A robust local AI infrastructure fully provisioned by Nix:

*   **Local LLMs**: Integrated **Ollama**, **LocalAI**, and **LM Studio**.
*   **Vector Power**: **ChromaDB** and **Qdrant** for RAG applications.
*   **Agents**: Pre-configured environments for **CrewAI**, **AutoGen**, and custom Python agents.
*   **Automation**: **n8n** workflow automation server and **Home Assistant** integration.

### 🛡️ Ship Security & Privacy
*   **Sops-Nix**: All secrets are encrypted at rest using Age encryption.
*   **Impermanence**: Root filesystems are wiped on boot; only strictly defined state is persisted (Persistence as Code).
*   **Headscale**: Secure mesh networking compatible with Tailscale.
*   **AdGuard Home**: Network-wide ad blocking and DNS privacy.

---

## 🛠️ Technology Stack (Flakes)

Managed via `flake.nix` and `flake-parts`:

| Flake | Description | Usage |
|:---|:---|:---|
| `clan-core` | Fleet Management | Modules, secrets, and deployment |
| `hyprland` | Window Manager | Tiling compositor and plugins |
| `home-manager` | User Environment | Dotfiles and user styling |
| `sops-nix` | Secrets Management | Encrypted secrets at rest |
| `impermanence` | State Management | Opt-in persistence for stateless root |
| `spicetify-nix` | Spotify Theming | Custom Spotify client theming |
| `nixos-facter` | Hardware Detection | Auto-configured hardware support |
| `llm-agents` | AI Tooling | Local AI agent environment |

---

## 🗺️ Architecture Structure

This configuration follows the **Clan-Core** architecture for scalable fleet management.

```mermaid
graph TD
    User[t0psh31f] -->|Manages| Flake[Flake.nix]
    Flake -- Imports --> Clan[Clan Inventory]
    
    subgraph Hosts
        Luffy[Luffy (Workstation)]
        Z0r0[Z0r0 (Media Server)]
    end
    
    subgraph Modules
        Core[Core System]
        Desktop[Desktop / Hyprland]
        Services[AI / Media / Infra]
    end
    
    Clan --> Luffy
    Clan --> Z0r0
    
    Luffy --> Core & Desktop & Services
    Z0r0 --> Core & Services
```

---

## � Setting Sail (Quick Start)

### Prerequisites
*   Nix enabled system (Linux/MacOS) with Flakes enabled.
*   `direnv` installed.

### 1. Recruit the Crew (Clone)
```bash
git clone https://github.com/T0PSH31F/NFP.git
cd NFP
direnv allow
```

### 2. Update the Ship (Deploy)
```bash
clan machines update z0r0
```

### 3. Unlock the Treasure (Secrets)
```bash
sops treasure/secrets/vicinae.yaml
```

---

## 📦 Allied Crews (Related Projects)

### [VegaNix Records](https://github.com/T0PSH31F/grandlix-devenvs)
*(Formerly Grandlix-Devenvs)*
A separate repository hosting reproducible development environments for Python, Node.js, Rust, and Go. Kept separate to minimize the closure size of the main system flake.

---

## 📸 Gallery

<p align="center">
  <img src="assets/screenshots/desktop_placeholder.png" alt="Desktop Screenshot" width="45%">
  <img src="assets/screenshots/dashboard_placeholder.png" alt="Dashboard Screenshot" width="45%">
</p>

---

## 📜 Pirate Code (License)

This project is licensed under the MIT License - see the LICENSE file for details.

---

<p align="center">
  <i>"I'm going to be the King of the Pirates!" — Monkey D. Luffy</i>
</p>
