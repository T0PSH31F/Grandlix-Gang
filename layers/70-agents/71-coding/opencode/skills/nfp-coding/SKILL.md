---
name: nfp-coding
description: Canonical NFP repository coding conventions and module creation guidelines.
---

# NFP Coding Guidelines

- Always follow dendritic module architecture under `layers/`.
- Never hardcode secrets — use `sops-nix` or `clan.core.vars`.
- Reference owning module options for all ports and endpoints.
