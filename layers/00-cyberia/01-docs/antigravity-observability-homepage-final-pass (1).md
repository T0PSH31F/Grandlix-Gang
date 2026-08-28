# Prompt for Antigravity: Observability + Homepage Final Pass + Re-Verification

Repo: github.com/T0PSH31F/NFP. This is a final-pass audit — re-verify every
prior prompt's checklist actually landed (don't trust that it "completed"
without checking), then close the observability and homepage gaps below.
Deploy via `clan machines update` only after everything verifies clean.

## Group 0 — Re-verify prior work actually landed
1. Re-run the verification checklists from `antigravity-hermes-multiagent-setup.md`,
   `antigravity-compat-fixes-and-profiles-audit.md`, and
   `antigravity-docs-readme-polish.md` (if merged). For each checklist item,
   confirm pass/fail against the current repo state, not against whatever
   was reported at the time. Report any item that silently regressed or was
   never actually completed.
2. Confirm the Managed Scope migration for Hermes is still intact (no new
   commit re-introduced `services.hermes-agent.settings` templating
   `~/.hermes/config.yaml` directly).

## Group 1 — Fix the broken (not just mislabeled) Langfuse panel
1. Confirm directly: `layers/20-services/26-monitoring/monitoring.nix`'s
   Prometheus `scrapeConfigs` currently has exactly two jobs (`prometheus`,
   `node`) — no `blackbox_exporter` is deployed anywhere in the repo.
2. The panel "Langfuse Trace Count" in `hermes-activity.json` queries
   `job="blackbox-hermes"`, which was never scraped — this returns zero
   data, it is not merely mislabeled. Either deploy `blackbox_exporter`
   properly (probe Hermes/Langfuse HTTP endpoints, add the scrape job,
   rename the panel to reflect uptime accurately) or remove the panel
   entirely and replace it with the real Langfuse-metrics panel from Group 2
   — do not leave a panel that silently shows nothing.

## Group 2 — Close the three missing observability pillars
1. **Metrics**: add `postgres_exporter` scraping for the Postgres/pgvector
   service, and a small custom exporter that polls Langfuse's
   `/api/public/metrics` endpoint and re-exposes trace count/token
   cost/latency as real Prometheus metrics — this replaces the broken panel
   from Group 1 with genuine data.
2. **Logs**: deploy Loki + promtail (or `services.loki`/`services.promtail`
   NixOS modules if available, else OCI containers matching the existing
   Langfuse pattern). Point promtail at journald for every service under
   `layers/20-services/` and `layers/70-agents/` at minimum. Add Loki as a
   Grafana datasource and one basic "recent errors across services" log
   panel.
3. **Notifications**: configure Grafana Alerting (or a standalone
   Alertmanager) with at least one rule (service-down, e.g. any scraped
   target unreachable for 5+ minutes) routed to a webhook. The user has
   Discord and Telegram bot connectors available — use whichever the user
   confirms they want notifications routed to (ask if unclear, don't assume).
4. Document all of the above in `layers/00-cyberia/01-docs/ai-stack.md` and
   a new `monitoring.md` if one doesn't already fit this scope — cover what
   each pillar covers, where to view it, and how to add a new service to
   each (new scrape target, new log source, new alert rule).

## Group 3 — Homepage: stop showing stale/wrong data
1. For every service in `layers/20-services/26-monitoring/homepage-dashboard.nix`,
   cross-check against actual `layers.*.enable` flags in the current config.
   Remove any entry referencing a decommissioned or never-actually-enabled
   service.
2. Rewrite the service-list generation to be conditional on Nix evaluation
   itself: build each group's entries with `lib.optionals cfg.someService.enable
   [ ... ]` (or equivalent) rather than a static list, so a service that's
   off in config never renders a card at all — this solves "only show
   what's configured" without needing runtime auto-discovery for native
   systemd services.
3. For every service that already runs as a Podman/oci-container (Langfuse
   and any others), enable Homepage's native Docker-label auto-discovery
   against the Podman socket (`homepage.group`/`homepage.name`/etc. labels
   on the container definition) so those services never need a manual
   homepage-dashboard.nix entry again, present or future.
4. For services with a real Homepage widget integration available
   (Grafana's `grafana` widget type, `customapi` for anything with a simple
   JSON status endpoint), replace the generic ping-only card with the
   richer widget — check gethomepage.dev's widget list per service before
   assuming only a ping is possible.
5. Add a Homepage `iframe` widget block for the Grafana dashboard (kiosk
   mode) per the earlier-scoped request, if not already done in a prior
   pass — verify it's actually present, don't just check the plan document.
6. Fix the ping/status-indicator CSS ballooning bug — re-verify it's
   actually fixed on both machines visually if a prior pass claimed this,
   since Group 0 requires confirming prior claims, not trusting them.
7. For every CLI-only service (no web UI, e.g. anything managed purely via
   its own CLI), confirm a doc entry exists explaining setup/interaction —
   if the docs-polish pass didn't cover this, add it now under
   `layers/00-cyberia/01-docs/services.md`.

## Group 4 — Deploy and confirm live
1. Update all touched documentation once more (`services.md`, `ports.md`,
   `ai-stack.md`, the new `monitoring.md`) to reflect the final state after
   Groups 1-3.
2. Run `clan machines update` across the fleet.
3. Post-deploy, verify LIVE (not just `nix eval`) on both `z0r0` and `luffy`:
   every dashboard loads with real data, Homepage shows only currently
   enabled services with correct widgets, Loki receives logs, and the
   notification channel receives a test alert.

## Verification checklist
- [ ] Prior-prompt checklists re-verified against current state, not trusted
- [ ] Langfuse panel either fixed with real data or removed — not left showing zero
- [ ] Metrics/logs/notifications pillars all have at least one working, verified path
- [ ] Homepage service list is conditional on actual enable flags, no stale entries
- [ ] Podman-containerized services use label auto-discovery, not manual entries
- [ ] CLI-only services documented
- [ ] `clan machines update` run; live verification (not eval-only) confirmed on both machines
