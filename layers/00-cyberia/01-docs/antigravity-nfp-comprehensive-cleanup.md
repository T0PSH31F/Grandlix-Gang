# Prompt for Antigravity: NFP Comprehensive Cleanup

Repo: github.com/T0PSH31F/NFP. Follow the repo's own harness rules: claim each
item in `feature_list.json` before starting it, provide verification evidence,
one PR per logical group below (do not bundle unrelated groups into one PR).
Run `./init.sh` first; if red, fixing baseline is your only task until green.

## Group 1 — Finish outstanding phase work (do this first)
1. Run `jq '.features[] | select(.status != "passing") | .name' feature_list.json`
   and report the full list of incomplete claims before doing anything else.
2. Check whether the Phase 6 "remaining program" PR referenced as a
   prerequisite in `ag-prompt-after-purification.md` is merged. If not,
   stop and report — do not proceed with Phase 4 or later work until it is.
3. Implement Phase 4 (Noctalia plugins + rofi sync) exactly as scoped in
   `ag-prompt-after-purification.md`: pin a `fetchFromGitHub`/`fetchzip` of
   the plugins repo (rev + hash), add
   `layers.layer-40.desktop.noctalia.plugins = [ ... ]` mapping plugin names
   to `symlinkJoin`/`linkFarm` output, symlinked into `~/.config/noctalia/plugins`.
   Verify by enabling a real community plugin and confirming it loads in the
   running shell, not just that the Nix option evaluates.
4. Complete any other items surfaced by step 1's query, in dependency order.

## Group 2 — Managed Scope migration (Hermes/OpenCode/Desktop config split)
Implement exactly as scoped in the companion prompt file
`hermes-managed-scope-migration-prompt.md` and `antigravity-hermes-multiagent-setup.md`
from this session. Do not duplicate — read those files first if present in
this session's history/output, otherwise reconstruct from:
- Split `services.hermes-agent.settings` into `/etc/hermes/config.yaml`
  (pinned) vs. untouched `~/.hermes/config.yaml` (user/GUI-mutable).
- Apply the same `mkOutOfStoreSymlink` treatment to OpenCode's config.
- Wire Kong-primary / ExtremeRouter-fallback provider config into the
  pinned layer.
- Build the shared skills/MCP module and profile-template distribution
  structure as previously scoped.

## Group 3 — Langfuse/Grafana observability fix
1. In `layers/20-services/26-monitoring/dashboards/hermes-activity.json`,
   rename the panel currently titled "Langfuse Trace Count" (querying
   `count(probe_success{job="blackbox-hermes"})`) to "Hermes Service Uptime"
   — it measures port availability, not trace data. Do not leave it
   mislabeled.
2. Add a new panel/dashboard sourced from Langfuse's actual Metrics API
   (`GET /api/public/metrics` on `127.0.0.1:3005`) — either via a small
   Prometheus exporter service (poll the API, expose `/metrics`, scrape it
   normally) or, if that's too much scope for this pass, add a Homepage
   `customapi` widget pointed directly at the Langfuse metrics endpoint for
   a lightweight stat display instead of faking it through Prometheus.
3. Document in `layers/00-cyberia/01-docs/ai-stack.md` that Langfuse has no
   native Prometheus endpoint upstream, so future agents don't try to wire
   a direct scrape job and waste time.
4. Check whether Loki is deployed anywhere in the stack. If not, and if the
   user wants searchable logs in Grafana (not just metrics), scope a
   follow-up feature claim for a Loki + promtail deployment — do not build
   it in this same PR, just record the claim.

## Group 4 — Homepage dashboard CSS fix
1. Reproduce the ping/status-indicator ballooning issue in a browser with
   dev tools open. Inspect the actual rendered element for the service
   ping/status dot and record its computed `height`/`overflow` values.
2. Compare against `layers/00-cyberia/02-assets/templates/homepage-theme.css`
   — the general widget-ballooning fix already applied (per
   `agent-progress.md`, "strict CSS height caps") evidently didn't cover
   this specific selector. Add an explicit `max-height`/`overflow: hidden`
   rule scoped to the ping/status-dot element specifically, matching the
   pattern already used for the general widget fix.
3. Verify visually on both machines (`z0r0`, `luffy`) post-rebuild, not just
   via `nix eval` — this is a rendering bug, evaluation success doesn't
   prove the fix.
4. Add a Homepage `iframe` widget block pointing at the Grafana dashboard
   (kiosk mode, e.g. `src: http://<host>:3008/d/<uid>?kiosk`) for at-a-glance
   observability from the homepage itself, per user request.

## Group 5 — Layer organization governance
The user has observed that agents have taken liberty defining their own
numbered layers over time, causing disorganization. Fix this structurally,
not just once:
1. Audit every directory under `layers/` and every subdirectory within each
   numbered layer. Produce a report of any numbering collisions, gaps, or
   subdirectories that don't follow the existing `NN-name` convention seen
   in `layers/70-agents/` (`71-coding`, `72-voice`, etc.).
2. Create `layers/NUMBERING.md` — a single canonical reference listing every
   currently-assigned number and name at both the top level (00-cyberia
   through 90-profiles) and within each layer's subdirectories, plus the
   *next available number* at each level and the semantic range each band
   is reserved for (e.g. "70-79 reserved for agent-related subsystems").
3. Add a CI check (extend `flake/checks.nix`) that fails if a new directory
   is added under `layers/` without a corresponding entry in
   `layers/NUMBERING.md` — this is the actual fix, since documentation alone
   won't stop the drift; a future agent session (including yourself) must
   be structurally blocked from inventing an ad hoc number.
4. Update `.agents/rules/organization.md` to require checking and updating
   `NUMBERING.md` as a mandatory step before creating any new layer
   directory, not just as a suggestion.
5. Do not silently renumber existing directories to "clean up" past drift in
   this same pass — that's a separate, disruptive migration. Only add the
   governance mechanism now; propose the renumbering migration as its own
   scoped feature claim for the user to approve separately.

## Group 6 — Address remaining findings from the prior review
Work through the 20 findings from this session's earlier repo review
(hardcoded `/home/t0psh31f` path in `hermes.nix`'s migration script, shared
provider-timeout defaults, feature_list.json archiving strategy, dashboard.nix
vs. homepage-dashboard.nix overlap check, mcp.nix vs. 75-mcp layer split
clarity, etc.) as a lower-priority cleanup pass after Groups 1-5 are merged.
List which findings you addressed and which you're deferring, with reasons.

## Verification checklist (report against this at the end)
- [ ] `jq` query against feature_list.json run and reported
- [ ] Phase 4 Noctalia plugins verified working with a real plugin, not just evaluating
- [ ] Managed Scope split live; Hermes Desktop toggle persists a rebuild
- [ ] Langfuse panel relabeled; real-metrics plan documented or implemented
- [ ] Homepage ping ballooning fixed and visually confirmed on both machines
- [ ] `layers/NUMBERING.md` exists and CI check enforces it
- [ ] One PR per group, each with feature_list.json evidence
