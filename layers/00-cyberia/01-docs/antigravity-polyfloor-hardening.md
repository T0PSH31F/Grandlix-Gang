# Prompt for Antigravity: Polyfloor Hardening

Repo: github.com/T0PSH31F/Polyfloor. This is an early-stage FastAPI scaffold
(routers/services/agents/auth/db/graph). Treat it as pre-production: prioritize
the persistence-layer gap first since it blocks every other improvement
(nothing else matters if there's no durable data to build on).

## Task 1 — Add a persistence layer (highest priority)
`backend/src/polyfloor/db/__init__.py` is currently empty and
`services/event_bus.py` appears to be in-process/ephemeral only, meaning
task/floor/event history doesn't survive a restart and cannot be aggregated
for analytics.
1. Add SQLModel (or SQLAlchemy directly, matching whatever's already in
   `pyproject.toml`/`uv.lock` if something's pinned) with SQLite as the
   initial backend — lowest friction for this project's current scale.
2. Define tables for: tasks (id, floor_id, status, created_at, completed_at,
   assignee/agent_id), floor events (from `event_bus.py`'s current event
   shape), and approvals (from `routers/approvals.py`'s current shape).
3. Wire `event_bus.py` to persist every event to the new tables in addition
   to (or instead of) whatever in-memory dispatch it currently does — check
   its actual current implementation before assuming it's pure in-memory,
   confirm with a test that restarts the process and checks data survives.
4. Add a migration tool (Alembic if SQLAlchemy, or the SQLModel-native
   approach) so schema changes don't require manual DB surgery later.

## Task 2 — Test coverage for the core value path
Only `backend/tests/test_auth.py` currently exists. The task-claim/execution
path is the actual point of this project and has zero coverage.
1. Add tests for `routers/tasks.py`: creating a task, claiming it, listing by
   floor_id/status filters, and the scope-gating (`require_scope`) behavior
   already used there.
2. Add tests for `agents/executor.py`'s task-packet creation and invocation
   flow.
3. Add tests for `routers/approvals.py`'s human-in-the-loop gating —
   specifically that a gated action cannot proceed without approval, and
   that approval/denial is recorded (once Task 1's persistence exists).
4. Confirm `routers/floors.py` and `routers/events.py` use `require_scope`
   consistently, matching the pattern already in `tasks.py` — add scope
   checks to any router missing them.

## Task 3 — Auth hardening (before any non-localhost exposure)
`auth.py`'s own docstring flags this as scaffold-only: static token from a
file, no database-backed tokens.
1. Once Task 1's persistence layer exists, migrate to database-backed
   tokens with: creation timestamp, expiry, revocation flag, and an audit
   log of which principal/scope made which request.
2. Do not expose this service beyond localhost/LAN until this migration is
   done — flag this explicitly in the README if it isn't already.
3. Keep the existing role/scope model (`require_scope`) as the authorization
   layer on top of the new token backend — it's a good pattern, don't
   replace it, just make the underlying token store durable.

## Task 4 — Wire in the Kong/ExtremeRouter provider config
`services/model_router.py` is the correct home for this, not per-agent
duplication:
1. Add `kong` as the primary provider and `extremerouter` as fallback,
   matching the config shape used in the NFP `hermes.nix`/profile-template
   work from this session (base_url/api_key/request_timeout_seconds per
   provider, model.fallback semantics).
2. Ensure `model_router.py` is the single call site every floor/agent uses
   for model selection — audit `agents/executor.py` and any floor
   definitions under `floors/` to confirm none of them hardcode a provider
   directly, bypassing the router.

## Task 5 — Deduplicate graph visualization effort
1. Inspect `backend/src/polyfloor/graph/` and compare its purpose against
   NFP's `.supergraph/` directory (a Nix module-dependency graph
   visualizer in the sibling NFP repo).
2. If they serve genuinely different purposes (Polyfloor's graph = agent/
   floor task dependency graph; NFP's = Nix module import graph), document
   that distinction clearly in both repos' READMEs so it's obvious to future
   contributors/agents they aren't redundant.
3. If they do overlap in practice, propose (don't implement without
   approval) consolidating on one visualization approach.

## Task 6 — Floor definitions as data, not code
1. Confirm `floors/` (repo root, outside `backend/`) is actually schema-
   validated and consumed at runtime by `routers/floors.py`, not just
   loosely read. Add a JSON Schema (or Pydantic model) that validates every
   file under `floors/` at startup, failing loudly if a floor definition is
   malformed — this matters more as the user's "HR" generator agent starts
   producing floor/profile definitions programmatically.

## Verification checklist
- [ ] Data survives a process restart (persistence layer working)
- [ ] Core task-claim path has test coverage, tests pass
- [ ] Auth token backend is database-backed with expiry/revocation (or
      explicitly still flagged scaffold-only in README if deferred)
- [ ] `model_router.py` is the single provider-selection call site
- [ ] Graph-visualization overlap with NFP documented or resolved
- [ ] Floor definitions schema-validated at startup
