# Agent Task — NFP System-Audit Tooling + CI/Cache Verification + Recovery ISO

> Agent-agnostic (Hermes/OpenCode/Antigravity/Zed). Harness rules apply
> (AGENTS.md Startup Workflow): claim each feature in feature_list.json first,
> run verification, record structured evidence, ONE PR per phase. nix fmt /
> flake check / deadnix / statix green at every commit.
> SEQUENCING: run AFTER any in-flight phases merge. All new modules must be
> purification-compatible: mkDendriticModule-wrapped, enable-gated, always-imported,
> no relative helper imports, no mkForce in profiles, no unjustified `or` fallbacks.

Repo: NFP — flake-parts + clan-core fleet (z0r0, luffy), numbered dendritic layers,
impermanence, clan vars, harmonia cache on :5000 (28-clan-services/nix-cache),
deploy.yml (fmt/deadnix/statix/schema/flake-check), build-iso.yml, and
update-flake-lock.yml (scheduled) already on main.

## PHASE 1 — System health audit tooling (claim: system-audit-tooling)

Goal: a first-class, repeatable performance + resource diagnostic that any agent
or the user can invoke three ways: as an opencode command (/system-audit), as a
shell alias (sysaudit), and as a skill agents load when diagnosing lag.

1. **The script** — `layers/00-cyberia/06-scripts/system-audit.sh` via
   pkgs.writeShellApplication (name `sysaudit`, declared runtimeInputs). Sections,
   each with PASS/WARN/FAIL lines and a final summary table:
   - Hardware baseline: sysbench cpu run; glmark2 (desktop only); fio seq read on
     the root disk (1G file, /tmp); compare against reference constants exposed as
     `layers.layer-10.system.audit.reference` options (per-machine expected
     sysbench score etc.) — flag >20% below reference as FAIL.
   - Thermals/power: sensors temps; detect throttling (intel: rdmsr/thermald logs,
     amd: zenpower if present); power-profiles-daemon state.
   - Live resources: 10s sampling of pidstat -u (top 5 CPU), iostat -x (await,
     %util), free -m + swap pressure, OOM kills in journal (24h).
   - Systemd health: systemctl --failed; units in restart loops (journalctl
     --since -1h | count of 'Started.*' per unit > 10 = WARN); systemd-analyze
     blame top 10.
   - Desktop-lag specials (desktop tag only): count matugen/theme reload chain
     fires in the last hour from the journal (the pkill -SIGUSR2 ghostty /
     kitty reload / pywalfox chain — frequency > 6/hour = WARN with a debounce
     recommendation); zjstatus command-block intervals < 5s = WARN; hyprland
     plugin load list; xwayland zombie processes.
   - Network/fleet: ping luffy/z0r0 over mesh, harmonia cache ping
     (nix store ping --store http://<cache-host>:5000).
   - Output: markdown report to stdout AND /var/lib/nfp-audit/<timestamp>.md
     (persisted), latest symlinked. Exit non-zero on any FAIL.
2. **Module** — `layers/10-system/19-optimizations/audit.nix`:
   `layers.layer-10.system.audit.enable` (default true on workstation/desktop),
   installs sysaudit to environment.systemPackages, declares the reference-score
   options per machine, persists /var/lib/nfp-audit, optional weekly systemd timer
   (default off) that appends to the report dir.
3. **Alias + command + skill** (all three surfaces):
   - shell alias `sysaudit` in the shared alias attrset (zsh/bash/nushell).
   - opencode command file `layers/70-agents/71-coding/opencode/commands/system-audit.md`
     so `/system-audit` runs the tool and triages the output.
   - skill `layers/70-agents/skills/system-health/SKILL.md`: when to load (user
     reports lag/slowness), the diagnose order (baseline → resources → systemd →
     desktop specials), and the known NFP suspects (matugen reload storms,
     crash-looping services, zjstatus intervals, impermanence /persist fill).
   - cheatsheet entry in the rofi cheatsheets.
4. Verification: run sysaudit on z0r0; report written to /var/lib/nfp-audit/;
   /system-audit resolves in opencode; `sysaudit` alias works in zsh.

## PHASE 2 — CI/CD verification + auto-merge (claim: cicd-update-pipeline)

update-flake-lock.yml exists (scheduled). Verify and complete the loop:
1. Confirm the lock-update PR triggers deploy.yml checks (pull_request trigger —
   add `types: [opened, synchronize, reopened]` if missing). The update PR must
   run: fmt, deadnix, statix, feature_list schema, nix flake check, BOTH machine
   evals. No green checks → no merge.
2. Add auto-merge on green for update-flake-lock PRs ONLY (gh pr merge --auto
   --squash, gated on all checks passing + author is the github-actions bot).
   Weekly cadence is fine; add a `workflow_dispatch` for manual runs.
3. Deploy stage (if not already landed from the earlier spec): on main, after
   checks, build both toplevels and push store paths to the harmonia cache; deploy
   stays manual-gated (clan machines update).
4. Verification: open a test PR bumping one input; show checks ran and auto-merge
   armed. Record the workflow run URL as evidence.

## PHASE 3 — Cache consolidation + decision (claim: cache-consolidation)

Current state is fragmented: 25-data/harmonia.nix is a stub with a conflict
comment + a sops secret; 28-clan-services/nix-cache is the real clan service;
90-profiles/tags/cache-server.nix points at services.harmonia.cache.enable.
1. Consolidate to the clan service ONLY: delete the 25-data stub (migrate its sops
   secret into clan vars if still referenced — prefer clan vars), rewrite
   cache-server.nix to assign the clan service's server role to the cache host
   (luffy — always-on) and client role to all machines.
2. Clients: substituters += http://luffy:5000 (mesh-reachable), trusted public key
   from the shared clan var. CI runners can't reach the LAN cache — keep
   magic-nix-cache-action in CI for that (free), and add a commented cachix
   snippet marked OPTIONAL (only needed if the repo's builds should be cacheable
   by outsiders/CI at scale — not needed while fleet is 2-3 machines; document
   this decision in the module comment).
3. Persist /var/lib/harmonia (or the clan service's state dir) under /persist.
4. Verification: on z0r0, `nix store ping --store http://luffy:5000` OK; then
   `nix build` of a path luffy already built and record download-vs-build timing
   evidence in feature_list.json.

## PHASE 4 — Baremetal recovery/installer ISO (claim: recovery-iso)

A lean live ISO for provisioning new bare metal with the NFP desktop, minus the
fleet's heavy tooling. Target < 20GB (should land far under; record actual size).
1. New module `layers/00-cyberia/07-iso/recovery.nix` (create the group; register
   in the tree) defining `nixosConfigurations.nfp-recovery` via
   (modulesPath + "/installer/cd-dvd/installation-cd-graphical-calamares.nix") as
   the base, with:
   - The desktop FOUNDATION only: hyprland neutral base + noctalia (or the
     experience selector default once the purification lands — wire to it if
     present, else direct noctalia), NetworkManager, firefox or librewolf, ghostty.
   - Recovery tooling: gparted, testdisk, ddrescue, smartmontools, nvme-cli,
     parted, rsync, rclone, git, helix + zellij, btop, iotop, clan CLI, sops, age,
     ssh with the user's persisted pubkey auth, tailscale (join mesh for remote
     rescue), disko.
   - EXCLUDE: all of 20-services AI stack, media stack, agents, games, theming
     extras beyond what the desktop needs. A `minimal` tag is a good mechanism —
     gate the ISO config on an explicit small tag list, not by disabling pieces.
   - isoImage settings: isoName = "nfp-recovery.iso", volumeID, squashfs
     compression defaults fine; include the NFP repo as a read-only payload at
     /etc/nfp for installs (`environment.etc."nfp".source = inputs.self` — note
     flake self-reference caveat: use cleanSource/self outPath carefully to keep
     the ISO from ballooning; if self-reference bloats the image, ship a
     fetchgit of the repo at the locked rev instead).
   - A `just`/`clan machines install` quickstart printed in the live session's
     motd/issue: partition with disko → clan machines install <new-host> → reboot.
2. Update build-iso.yml: build `.#nixosConfigurations.nfp-recovery.config.system.build.isoImage`,
   upload the .iso as a release artifact on tag pushes (v*-iso) and as a workflow
   artifact on manual dispatch. Keep it out of per-PR CI (too heavy) — dispatch +
   tags only.
3. Verification: build succeeds; ISO size < 20GB recorded as evidence; boot the
   ISO in a VM (nixosTest or manual qemu) reaching the desktop; note the smoke
   result in agent-progress.md.

## Acceptance criteria

- sysaudit runs from alias AND /system-audit AND is loadable as a skill; report
  persisted; a WARN/FAIL example recorded in evidence.
- flake-lock PRs run the full check suite and auto-merge only when green.
- One harmonia implementation remains; cache ping + download-vs-build timing
  evidence recorded; cachix decision documented as a comment.
- nfp-recovery ISO builds in CI on dispatch, < 20GB, boots to desktop in a VM
  smoke test, contains recovery tools and NOT the AI/media stack.
- All claims passing in feature_list.json with structured evidence; docs updated
  (architecture.md gains an "Operations" section: sysaudit, cache, ISO, CI loop).
