# NFP Agent Harness Specification & Lifecycle

The NFP Agent Harness transforms the repository into the single system of record for all autonomous and pair-programming agent operations across the fleet (`z0r0` and `luffy`).

---

## 1. Harness Pack Components (Repo Root)

| File | Purpose |
| --- | --- |
| `init.sh` | Execution entry point for starting agent sessions. Enforces nix fmt, flake check, and machine evals. |
| `feature_list.json` | Live feature registry tracking IDs, priorities, behaviors, verification steps, states (`untried`, `in-progress`, `blocked`, `passing`), and evidence logs. |
| `agent-progress.md` | Append-only historical session log recording agent actions, verification commands, state changes, and next steps. |
| `session-handoff.md` | Overwritten compact state file summarizing the active feature, last verified green status, and immediate next commands. |
| `clean-state-checklist.md` | End-of-session verification checklist ensuring clean formatting, evaluation, documentation, and git state. |
| `evaluator-rubric.md` | 6-category evaluation rubric (Correctness, Verification, Convention, Persistence, Secrets, Docs) scored 0–2. |

---

## 2. Session Lifecycle Protocol

1. **Initialize Session**: Run `./init.sh`. If baseline check fails, repair baseline before feature work.
2. **Read Context**: Inspect `agent-progress.md` and `session-handoff.md`.
3. **Select Feature**: Open `feature_list.json` and claim exactly ONE feature not in `passing` state.
4. **Implementation**: Execute changes according to rules in `.agents/rules/` and skill guidelines in `layers/70-agents/skills/`.
5. **Verification**: Run every command listed under the feature's `verification` property. Save exact CLI outputs as evidence.
6. **Self-Evaluation**: Score work against `evaluator-rubric.md` (Total $\ge 8$, no category at 0).
7. **Closeout**: Update `feature_list.json` with state & evidence, append entry to `agent-progress.md`, overwrite `session-handoff.md`, complete `clean-state-checklist.md`, and commit changes.

---

## 3. Skill Packs (`layers/70-agents/skills/`)

Canonical shared skills:
- **`harness-session-protocol`**: Enforces strict single-feature lifecycle and evidence collection.
- **`nfp-module-authoring`**: Guidelines for dendritic layer placement, options declaration, persistence, secrets, and docs.
- **`persistence-audit`**: Step-by-step verification of service state persistence under impermanence.

These skills are automatically symlinked into OpenCode (`layers/70-agents/71-coding/opencode/skills/`) and Hermes (`/var/lib/hermes/.hermes/skills/`).

---

## 4. How to Add a New Feature

Add an entry to `feature_list.json` under `"features"`:
```json
{
  "id": "feature-id",
  "priority": 2,
  "name": "Human Readable Feature Title",
  "behavior": "Detailed description of expected behavior",
  "verification": [
    "command to run and verify behavior"
  ],
  "state": "untried",
  "evidence": []
}
```
