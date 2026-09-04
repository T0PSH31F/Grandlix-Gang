# NFP Service Placement Refactoring Plan

**Repo:** T0PSH31F/NFP (NixOS/Clan flake)
**Date:** 2026-09-02
**Status:** In progress

---

## Current Problems

1. **ai-server + ai-agent tags enabled everywhere** — turns on heavy services on z0r0 node (steals RAM from dev tools), on sanji (pulls in Postgres/Honcho unnecessarily), and on luffy (pulls in agents there too).
2. **ExtremeRouter + OmniRoute both default to port 20128** — safe per-host but confusing and not explicit.
3. **Kong's `routers.codingRouter = "extreme-router"`** is correct for z0r0 but Kong on sanji should route to OmniRoute; currently OmniRoute isn't set as the sanji coding router anywhere.
4. **Multiple network overlays** — Tailscale + ZeroTier + WireGuard all active.
5. **luffy is down** — SSH connection refused after NixOS update; likely SOPS secret reflection failure (luffy not in `.sops.yaml`).
6. **No resource limits on sanji/luffy** — services compete for all memory.

---

## Implementation Plan — 6 Workstreams

### Workstream 1: Tag Refactor (New Modules)

**New file: `layers/90-profiles/tags/ai-router.nix`**

```nix
{ config, lib, ... }:
{
  config = lib.mkIf (lib.elem "ai-router" config.machine.tags) {
    services.ai-services.kong-gateway.enable = lib.mkDefault true;
    services.ai-services.omniroute.enable = lib.mkDefault true;
    services.ai-services.freellmapi.enable = lib.mkDefault true;
    services.ai-services.freellmpool.enable = lib.mkDefault true;
    infrastructure.langfuse.enable = lib.mkDefault true;
    services.headscale-server.enable = lib.mkDefault true;
    layers.layer-20.services.config.tailscale.enable = lib.mkDefault true;
    layers.layer-20.services.backups.restic.enable = lib.mkDefault true;
  };
}
```

**New file: `layers/90-profiles/tags/agent-orchestrator.nix`**

```nix
{ config, lib, ... }:
{
  config = lib.mkIf (lib.elem "agent-orchestrator" config.machine.tags) {
    layers.layer-76.hermes.enable = lib.mkDefault true;
    layers.layer-76.hermes.enableDesktop = lib.mkForce false;
    layers.layer-76.hermes-dashboard.enable = lib.mkDefault true;
    layers.layer-75.mcp.enable = lib.mkDefault true;
    layers.layer-70.agent.sandbox.enable = lib.mkDefault true;
    layers.layer-20.services.mission-control.enable = lib.mkDefault true;
    layers.layer-20.services.paperclip.enable = lib.mkDefault true;
    layers.layer-20.services.todo-system.enable = lib.mkDefault true;
    layers.layer-20.services.config.tailscale.enable = lib.mkDefault true;
  };
}
```

**New file: `layers/90-profiles/tags/pkb-node.nix`**

```nix
{ config, lib, ... }:
{
  config = lib.mkIf (lib.elem "pkb-node" config.machine.tags) {
    services.ai-services.postgresql.enable = lib.mkDefault true;
    services.ai-services.brain-service.enable = lib.mkDefault true;
    services.honcho.enable = lib.mkDefault true;
    layers.layer-20.services.config.monitoring.enable = lib.mkDefault true;
    layers.layer-20.services.config.tailscale.enable = lib.mkDefault true;
    layers.layer-20.services.backups.restic.enable = lib.mkDefault true;
  };
}
```

**Update `layers/90-profiles/tags/ai-server.nix`** — keep but add deprecation notice; stop assigning `ai-server` to any machine.

**Update `machines/z0r0/default.nix`** (add overrides):
```nix
# z0r0 — ExtremeRouter only (no OmniRoute, no FreeLLM, no server infra)
services.ai-services.omniroute.enable = lib.mkForce false;
services.ai-services.freellmapi.enable = lib.mkForce false;
services.ai-services.freellmpool.enable = lib.mkForce false;
```

**Update `machines/sanji/default.nix`** (add overrides):
```nix
# sanji — enable ai-router and agent-orchestrator
# Disable pkb-node and ai-agent (memory/local inference not on VPS)
services.honcho.enable = lib.mkForce false;
services.honcho.api.enable = lib.mkForce false;
```

---

### Workstream 2: Route Config — ExtremeRouter on z0r0, OmniRoute on sanji

**Current state:** Both ExtremeRouter and OmniRoute use port 20128 by default. Not a port conflict but confusing.

**Fix:** No port change needed; semantics are clear from module source. Add comments to each machine.

In `machines/z0r0/default.nix`, add:
```nix
# z0r0: ExtremeRouter as sole coding router at localhost:20128  
# KongRouter.js config on z0r0 MUST point codingRouter -> "extreme-router"
```

In `machines/sanji/default.nix`, add:
```nix
# sanji: OmniRoute as coding router at localhost:20128
# services.ai-services.omniroute.enable = true; (set by ai-router tag)
# Make sure kong-gateway points codingRouter -> "omniroute"
services.ai-services.kong-gateway.routers.codingRouter = "omniroute";
```

Update `sets-30-profiles/ai-server.nix` (now deprecated):
```nix
# ai-server is deprecated. Use ai-router + pkb-node tags instead.
# Removing all content; file kept for reference only.
{ ... }: { }
```

---

### Workstream 3: Headscale/Tailscale simplification

**Current:** Headscale is in `homelab` tag (luffy only). Tailscale in `server` tag (both luffy + sanji). ZeroTier on all 3 via Clan inventory.

**Fix:**
1. **Change Headscale responsibility:** Define Headscale’s `server_url` dynamically (use Headscale’s own Tailscale IP) or hard-code to the sanji control-plane IP once known. Move Headscale enable from `homelab.tag` overrides to `ai-router` tag (sanji).

2. **Update `headscale.nix`:**
   ```nix
   # settings.server_url should be the Tailscale FQDN of whichever node runs Headscale
   # Currently: "https://headscale.lovelain.duckdns.org"
   # Change to: use Headscale's actual FQDN once DNS points there
   ```

3. **ZeroTier:** Comment out or remove from Clan inventory `instances.zerotier`; keep module file for future use. Remove firewall rule 9993 per-machine to avoid waste.

4. **Update `.agents/rules/` docs** to state: "Only one mesh layer: Tailscale. ZeroTier and raw WireGuard are deprecated for now."

---

### Workstream 4: luffy SOPS + Password Recovery

**Problem:** `.sops.yaml` `creation_rules` area only includes z0r0 and z0r0_host age keys. Encrypted secrets for luffy (e.g., user passwords in `clan secrets`) cannot be decrypted.

**Steps:**
1. Generate a machine age key for luffy:
   ```bash
   # On z0r0:
   cd /path/to/NFP
   mkdir -p secrets/luffy/age
   ssh root@luffy "cat /etc/ssh/ssh_host_ed25519_key" > secrets/luffy/age/host.key
   nix shell nixpkgs#age -- age-keygen -o secrets/luffy/age/users/t0psh31f.key
   # For user password: generate an age key pair in sops and store pubkey
   ```

2. Update `.sops.yaml`:
   ```yaml
   keys:
     - &z0r0 age10g...
     - &z0r0_host age13yt...
     - &luffy <NEW_LUFFY_AGE_PUBKEY>
     - &luffy_host <HOST_AGE_PUBKEY>
   creation_rules:
     - path_regex: secrets/.*\.yaml$
       key_groups:
         - age:
             - *z0r0
             - *z0r0_host
             - *luffy
             - *luffy_host
   ```

3. Manually set t0psh31f password on luffy (one-time):
   ```bash
   # Boot luffy into single-user kernel init= rescue mode
   # Or use cloud console if headless
   # Then:
   passwd t0psh31f
   ```

4. Re-encrypt SOPS secrets if needed and test on luffy.

---

### Workstream 5: Resource Limits (sanji + luffy)

**Extend `layers/10-system/19-optimizations/resource-limits.nix`** by adding entries in the existing `systemd.services` attrset:

```nix
# Kong gateway — headless, should not hog memory
kong-gateway = {
  serviceConfig = {
    Slice = lib.mkForce "background.slice";
    MemoryHigh = "1G";
    MemoryMax = "2G";
    CPUQuota = "50%";
  };
};
# OmniRoute
omniroute = {
  serviceConfig = {
    Slice = lib.mkForce "background.slice";
    MemoryHigh = "1G";
    MemoryMax = "2G";
    CPUQuota = "50%";
  };
};
# brain-service (LlamaIndex + pgvector)
brain-service = {
  serviceConfig = {
    Slice = lib.mkForce "background.slice";
    MemoryHigh = "3G";
    MemoryMax = "4G";
  };
};
# Honcho game API + deriver
honcho-api = {
  serviceConfig = {
    Slice = lib.mkForce "background.slice";
    MemoryHigh = "1G";
    MemoryMax = "2G";
  };
};
# Langfuse
langfuse-exporter = {
  serviceConfig = {
    Slice = lib.mkForce "background.slice";
    MemoryHigh = "512M";
    MemoryMax = "1G";
  };
};
```

These apply only where the service exists (modular).

---

### Workstream 6: Next Steps (requires user decision)

- Qdrant/ChromaDB: deactivated. Poetry (reuse/keep).
- gno local package: compile from local icon uses `src/everos` as mentioned locally.
- Banish `gno-main.zip` with Nix package? (Future work)
- Headscale DNS: point `headscale.lovelain.duckdns.org` at sanji’s Tailscale IP.

---

## File Mutation Summary

| File | Action |
|------|--------|
| New `layers/90-profiles/tags/ai-router.nix` | Create |
| New `layers/90-profiles/tags/agent-orchestrator.nix` | Create |
| New `layers/90-profiles/tags/pkb-node.nix` | Create |
| `layers/90-profiles/tags/ai-server.nix` | Deprecate (clear content, keep file) |
| `machines/z0r0/default.nix` | Add overrides: deny Omn
ureRoute/FreeLLM; deploy target to sanji Tailscale IP
`machines/sanji/default.nix` | Add overrides: enable ai-router+agent-orchestrator; Kong codingRouter=omniroute
`machines/luffy/default.nix` | Confirm no ai-router/agent-orchestrator; no Ztatic` hands
`clan.nix` | Update sanji tags; update z0r0 tags
`layers/10-system/19-optimizations/resource-limits.nix` | Add kong-ghwellhead, computedor, brain-service, Joygood memory limits for sanji/luffnient
`.sops.yaml` | Add luffy and sanji age keys; update creation_rules
`layers/20-services/21-networking/headscale.nix` | Default server_url to Tailscale FQDN of sanji (once provisioned)
`layers/90-profiles/tags/homelab.nix` | Move stuffy own if only semantics.
`layers/20-services/21-networking/zerotier.nix` | Add deprecation comment; no behavior change.

---

## Execute Now

I will now implement **Workstream 1: Tag Refactor**, then deploy and verify on the live machines.
