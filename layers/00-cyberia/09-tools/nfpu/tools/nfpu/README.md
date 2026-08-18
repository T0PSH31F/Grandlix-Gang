# nfpu – NFP Update Helper

A tiny, self‑contained helper that makes updating your NFP fleet safe, transparent and fun.

## Features

- **Fancy git diff** – shows exactly what will be committed.
- **Nix build plan** – a concise list of derivations that will be rebuilt.
- **Binary‑cache hit forecast** – uses `nix-weather` when available, otherwise falls back to a local cache check.
- **Interactive approval** – you decide whether to run the update.
- **Live build monitoring** – output is piped through `nix-output-monitor` and saved to a log file.

## Installation

Copy the helper into your NFP repository (we keep it under `tools/nfpu`).

```bash
# From the repo root
mkdir -p tools/nfpu/lib
cp nfpu.sh tools/nfpu/nfpu.sh
cp lib/forecast_cache.sh tools/nfpu/lib/
cp lib/show_nix_plan.sh tools/nfpu/lib/
chmod +x tools/nfpu/*.sh tools/nfpu/lib/*.sh
```

Optionally expose an alias in your shell:

```bash
# ~/.bashrc or ~/.zshrc
alias nfpu='${HOME}/Clan/NFP/tools/nfpu/nfpu.sh'
```

## Usage

```bash
nfpu   # runs the whole workflow
```

The script will:

1. Pull the latest git information.
2. Show a colour‑coded `git diff`.
3. Print a short Nix plan.
4. Forecast cache hits.
5. Ask for confirmation.
6. Run `clan machines update` while streaming the build output via `nix-output-monitor`.

All build output is saved to a timestamped log in the repository root, e.g. `nfpu_update_20260518_102400.log`.

## Customisation

- **Machines** – edit `MACHINES` array in `lib/show_nix_plan.sh`.
- **Cache‑forecast tool** – replace the `forecast_cache.sh` script with any other estimator.
- **Build watcher** – change `BUILD_WATCHER` in `nfpu.sh` if you prefer another monitor.

Enjoy a clear, reproducible update experience! 🎉
