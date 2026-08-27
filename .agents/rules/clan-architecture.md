---
trigger: always_on
description: Clan Architecture and Variables Rule Set
---

# 🛡️ Clan Architecture & Variables Strategy

## 1. The Golden Rule of Secrets & Variables
**NEVER** hardcode secrets, API keys, passwords, or sensitive environment variables directly into Nix files or use `pkgs.writeText` to bypass evaluation errors.
**ALWAYS** use the `clan.core.vars` framework as the sole preference for any sensitive data injection.

### Why Clan Vars?
Clan vars provide a declarative, reproducible, and type-safe way to manage generated files.
- **Type Safety**: The vars system distinguishes between secret files (accessible via `.path`, deployed to `/run/secrets/` and NEVER stored in the Nix store) and public files (accessible via `.value`).
- **Separation of Concerns**: Generation logic, storage (sops backend), and deployment are handled by Clan core logic.
- **Reproducibility**: Defined once and generated consistently across deployments.

### 1.1 Secrets System Boundary (Clan Vars vs SOPS-Nix)
- **`clan.core.vars`**: Primary boundary for all machine-scoped service secrets, container API tokens, auto-generated database credentials, and machine-bound service tokens.
- **`sops-nix`**: Reserved strictly for central legacy user secrets (`external_services.yaml`, `vicinae.yaml`, `postgres.yaml`) shared across users or legacy global endpoints. All new machine services MUST use `clan.core.vars`.

## 2. Implementing Clan Vars for Services
When introducing a new service or migrating an existing one that requires secrets, you must declare a Clan generator inside the module configuration block.

### Implementation Pattern:
```nix
# 1. Define the generator
clan.core.vars.generators.<service_name> = {
  files."<secret_filename>" = {
    secret = true; # Ensures the secret is NOT copied to the Nix store
    owner = "<service_user>";
    group = "<service_group>";
  };
  prompts."<secret_filename>" = {
    type = "hidden";
    description = "Description of the secret for the CLI prompt";
  };
};

# 2. Consume the generator
services.<service_name>.api_key_file = 
  config.clan.core.vars.generators.<service_name>.files."<secret_filename>".path;
```

### Feeding Variables via CLI
Once the Nix code is committed, instruct the user to execute the Clan CLI to securely store the secret using the SOPS backend:
```bash
clan vars set <machine_name> <service_name> <secret_filename>
```

## 3. Flake-parts & Clan Composition Principles
This repository relies heavily on the `flake-parts` framework combined with `clan-core`. When modifying the architecture, future agents must adhere to the following principles:

- **Modularity**: Flake-parts encourages isolating modules (`perSystem`, `flake` exports). Services must be self-contained in their respective layer (`layers/20-services/`).
- **Dependencies**: Clan generators can depend on the output of other generators. This creates a directed acyclic graph (DAG), useful for certificate authorities, mesh networks, or interconnected services.
- **Imperative Generation, Declarative Linking**: The Clan CLI handles the imperative task of prompting for secrets and encrypting them via `sops-nix` or `age`. The Nix module handles the declarative linking (`.path`). Do not try to bypass the imperative phase by writing dummy paths into the NixOS derivations.
- **Timing & Lifecycle (`neededFor`)**: If a secret is required extremely early in the boot sequence (e.g., by ZFS or networking), ensure you define `neededFor = "users";` or similar on the var generator so it is decrypted in time.

## 4. Execution Check
Before finalizing any module that connects to external endpoints or protects local databases:
1. Have all API keys, tokens, and passwords been offloaded to `clan.core.vars.generators`?
2. Has the `secret = true;` flag been applied to prevent Nix store leaks?
3. Have the appropriate file permissions (`owner`, `group`) been set on the generator?
