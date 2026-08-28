# Prompt for Antigravity/Hermes: Public Docs & README Polish

Repo: github.com/T0PSH31F/NFP. This is the user's primary professional
portfolio project and is publicly visible — treat every change here as
something a hiring manager or fellow engineer might read cold, with zero
prior context. Do not touch layer numbering or restructure directories in
this pass — that's a separate, user-supervised effort. This pass is purely
documentation quality and accuracy.

## Task 1 — README.md overhaul
1. Rewrite the README to read well for a stranger, top to bottom:
   - Clear one-paragraph statement of what this repo is and why it exists
     (a personal NixOS fleet config demonstrating declarative
     infrastructure, AI-agent orchestration, and reproducible desktop
     environments) before any implementation detail.
   - A short "why this is interesting" section highlighting genuinely
     differentiated things: the dendritic layer architecture, the
     feature-claim/evidence tracking system in `feature_list.json`, the
     multi-agent Hermes profile system, impermanence + btrfs rollback setup.
   - A real quickstart section a stranger could follow (clone, what they'd
     need, what `./init.sh` does) — verify it's actually accurate against
     the current `init.sh`, don't just polish stale prose.
   - Architecture section with a simple diagram or clear layer-band table
     (00-90) — keep this generic ("layers are organized by numbered band,
     see `layers/NUMBERING.md`" once that exists) rather than hardcoding
     specifics that will go stale the moment the numbering pass happens.
   - Screenshots or a short description of the desktop environment /
     Noctalia shell if screenshots aren't feasible to generate here — flag
     for the user to add real screenshots rather than fabricating placeholders.
2. Remove or genericize any content that references the user's literal
   home directory path or local hostnames in a way that looks like an
   oversight rather than an intentional example (e.g. `/home/t0psh31f`
   appearing in prose, not just in a code block demonstrating a real path).
3. Check for broken/stale links, badges pointing at CI that doesn't exist,
   and any TODO markers left in the README that shouldn't be public-facing.

## Task 2 — Docs directory consistency pass
For every file under `layers/00-cyberia/01-docs/` (`architecture.md`,
`features.md`, `services.md`, `ports.md`, `ai-agents.md`, `ai-stack.md`,
`hermes-agent.md`, `post-rebuild-setup.md`, etc.):
1. Proofread for grammar, clarity, and internal consistency — these are
   working documents, some clearly written mid-refactor; they should read
   as finished reference docs, not session notes.
2. Cross-check factual claims against actual current code — e.g. confirm
   `services.md`'s port table matches what's actually declared in the
   relevant `.nix` files right now, not what was true when the doc was
   written. Flag (don't silently fix) anything that reveals a real
   discrepancy rather than a docs typo, since that could indicate a
   deployment drift worth the user's attention.
3. Do NOT update any of these docs to reflect the new layer numbering
   scheme discussed separately with the user — that hasn't been finalized
   yet. Leave numbering-specific content as-is for now and note in your
   final report which docs will need a follow-up pass once renumbering
   lands.
4. Remove any doc content that's clearly internal scratch/planning material
   not meant for public consumption (distinguish this from the phase-task
   docs like `ag-prompt-after-purification.md`, which can stay since they
   demonstrate the agent-workflow methodology — that's a portfolio strength,
   not clutter, keep it but make sure it reads coherently to an outside
   reader too).

## Task 3 — Secret/PII sanity sweep
1. Grep the entire repo (not just docs) for anything that looks like a
   plaintext credential, API key pattern, or personal information that
   isn't already sops-encrypted. This repo is public — a mistake here is
   not cosmetic.
2. Confirm `.sops.yaml` and `.gitignore` actually cover everything they
   should — spot-check that no `*.env` or unencrypted secret file has ever
   been committed in git history (`git log --all --full-history -- '*.env'`
   or similar), not just that the current tree looks clean.
3. Report findings before making any destructive git-history changes
   (history rewriting to purge a leaked secret needs the user's explicit
   sign-off, not autonomous action).

## Task 4 — Consistency with AGENTS.md
Confirm `AGENTS.md` (the agent operating instructions) and the public-facing
docs don't contradict each other about workflow (e.g. if AGENTS.md says
"claim in feature_list.json before starting," make sure any public
contributor-facing doc says the same thing, if one exists or gets added).

## Verification checklist
- [ ] README reads coherently to someone with zero prior context
- [ ] Quickstart steps verified accurate against current `init.sh`
- [ ] No stale links/badges/TODOs left in public-facing docs
- [ ] Docs directory internally consistent and factually current
- [ ] No unencrypted secrets found in current tree or git history (or
      findings reported to user if any are found)
- [ ] Clear note on which docs need a follow-up pass after the layer
      renumbering session happens
