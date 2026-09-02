# Session Handoff

> Compact state for the next session. Overwrite entirely at the end of each session.

- **Active feature:** kong-extremerouter-enumeration-fix (passing — evidence recorded)
- **Last verified green:** `clan machines update z0r0` activation succeeded; `curl :8090/v1/models` → 200/538 models; `curl -X POST :8090/v1/chat/completions` → 200 SSE; both z0r0 & luffy toplevels eval clean.
- **Blockers:** none (for this feature)
- **Follow-ups:**
  - `paperclip.service` crash-loops with "No config found and terminal is non-interactive. Run `paperclipai onboard` once" — one-time onboarding needed (pre-existing, separate from Kong fix).
  - `extremerouter_api_key` secret (`sk-691f04…`, the ExtremeRouter dashboard "Kong Key") now stored in sops `external_services.yaml`.
  - `manifest-llm` upstream (port 2099) is DOWN — legacy frontier route only, not on the critical agent path.
- **Exact next command:** `./init.sh` (or commit + `git push` the Kong routing fix, then open a PR)
- **Do not touch:** `clean-state-checklist.md` on main (must remain an unchecked template)

## Key facts for next session

### Kong (self-hosted, flake-managed — NOT Kong Konnect SaaS)
- `8090` = proxy (agents call `/v1/*` here); `8091` = Admin API (loopback); `8093` = Manager GUI/dashboard (loopback: `http://127.0.0.1:8093`).
- Image `kong/kong-gateway:latest` (3.15.0.5-enterprise-edition), DB-less declarative config.
- Config merged in `podman-kong` ExecStartPre from `kongYml` + sops `kong-consumers` + sops `kong-extremerouter-auth` using a `deep_merge` jq (array-concatenating).

### ExtremeRouter
- Port `20128`, data dir `/var/lib/extreme-router` (owned by `t0psh31f`), `requireApiKey: true`.
- Remote API key ("Kong Key") = `sk-691f0427f4be6db5-y12o28-38dff348`, also stored as sops `extremerouter_api_key`.

### Deployment
- Always `clan machines update z0r0` (never raw nixos-rebuild).
