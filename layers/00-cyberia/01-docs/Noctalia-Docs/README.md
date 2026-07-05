# Noctalia Desktop Shell

> NFP uses **Noctalia v5** (native C++/OpenGL ES shell, not the Quickshell-based v4).

## Documentation

All Noctalia v5 documentation lives at: **https://docs.noctalia.dev**

### Key pages for NFP maintainers

| Topic | URL |
|-------|-----|
| Overview | https://docs.noctalia.dev/v5/ |
| NixOS installation | https://docs.noctalia.dev/v5/getting-started/nixos/ |
| Running the shell | https://docs.noctalia.dev/v5/getting-started/running-the-shell/ |
| Hyprland compositor settings | https://docs.noctalia.dev/v5/compositor-settings/hyprland/ |
| Configuration model | https://docs.noctalia.dev/v5/configuration/ |
| Bar & widgets | https://docs.noctalia.dev/v5/bar/ |
| Theming | https://docs.noctalia.dev/v5/theming/ |
| IPC commands | https://docs.noctalia.dev/v5/ipc/ |
| Greeter | https://docs.noctalia.dev/v5/greeter/ |
| FAQ | https://docs.noctalia.dev/v5/getting-started/faq/ |

## NFP-specific notes

- **Flake input**: `github:noctalia-dev/noctalia/cachix` (pins to latest cached commit)
- **Binary cache**: `noctalia.cachix.org` configured in `layers/10-system/11-foundation/caches.nix`
- **Backend**: Hyprland on both z0r0 and luffy
- **Config**: Home Manager module via `inputs.noctalia.homeModules.default`
- **Systemd**: `programs.noctalia.systemd.enable = true`
- **Greeter**: `noctalia-greeter` (not SDDM, not greetd/ReGreet)
- **Config files**: `layers/40-desktop/43-noctalia/default.nix`, `ipc.nix`, `mutable-includes.nix`
- **v4 (Quickshell) is no longer used** — all Quickshell references in the codebase are dead code
