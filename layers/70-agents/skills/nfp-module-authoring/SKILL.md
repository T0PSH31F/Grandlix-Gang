---
name: nfp-module-authoring
description: How to add or modify a dendritic module in NFP — layer placement, namespacing, persistence, secrets, docs.
---

# NFP Module Authoring

Use when creating or editing anything under `layers/`.

- Placement: services -> `layers/20-services/<group>/<name>.nix`; agents -> `layers/70-agents/<group>/<name>.nix`.
- Options: declare under `layers.layer-XX.<group>.<name>` (never new `services.ai-services` at top level).
- Wrap with `mkDendriticModule` per the layer's existing pattern; support dual NixOS/Home-Manager options if applicable.
- State: if the module has runtime state, add the `environment.persistence."/persist"` block matching user/group/mode.
- Secrets: clan `vars/` only (see `layers/20-services/22-ai/kong-secrets.nix`). Never hardcode secrets.
- Firewall/ports: open ports in the module; record them in `layers/00-cyberia/01-docs/ports.md`.
- Done means: evals clean on both machines, docs updated, feature_list evidence recorded.
