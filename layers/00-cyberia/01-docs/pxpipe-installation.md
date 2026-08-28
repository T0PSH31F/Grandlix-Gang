# pxpipe Non-Nix Installation Pattern

`pxpipe` is intentionally maintained outside the Nix store derivations.

## Installation Instructions

Install via `pipx` or `uv`:

```bash
# Using pipx
pipx install pxpipe

# Or using uv
uv tool install pxpipe
```

## State & Persistence

- `pipx` binaries and virtualenvs reside in `~/.local/share/pipx` and `~/.local/bin`.
- `uv` tools reside in `~/.local/state/uv` and `~/.local/bin`.
- User `.local` directory is persisted across reboots under `/persist/home/t0psh31f/.local` via impermanence.
