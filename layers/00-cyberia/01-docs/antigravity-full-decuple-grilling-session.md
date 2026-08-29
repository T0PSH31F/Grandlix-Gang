# Prompt for Antigravity: Full Layer Renumbering — Decuple-by-Decuple Interview

Repo: github.com/T0PSH31F/NFP. Your job is to INTERVIEW the user to a
complete, final numbering decision across every decuple (00 through 90).
Do NOT move, rename, or renumber a single file until the user has typed the
literal word "apply" in response to your final summary. Work through the
decuples below strictly IN ORDER, one at a time. Do not move to the next
decuple until the current one has an explicit, unambiguous answer. If the
user is vague, ask a narrower follow-up rather than assuming.

## Standing rules, established across this conversation — do not re-litigate
- Numbering only at depth 1-2 using dash-notation (`NN-name`). Depth 3+ uses
  dot-notation (`NN.M`) for small, stable enumerations, never another
  dash-number (this is what caused the original `22-ai/25-harness-control`
  collision — a depth-3 dir using the same dash format as a top-level band).
- Guiding philosophy for `NUMBERING.md`: numbered layers (00-89, whatever the
  final range ends up being) are "nouns" — what exists. Layer 90 (tags/
  profiles) is "verbs" — how nouns combine for a use case.
- Organizing principle, in the user's own words: separate by area of
  concern/program first, group by use-case/activity second. Any item that's
  "what tool" belongs in a numbered layer; anything that's "which scenario"
  belongs in tags/profiles (or "activities," pending decuple 80's outcome).
- The 700-word-per-module guideline was discussed but the user is not
  prioritizing it in this pass — do not bring it up unless the user does.

## Before starting: pull current state
Run a fresh audit of `layers/` (every top-level dir and every immediate
subdirectory) and present it as a table before asking any questions, so both
you and the user are working from the same ground truth, not memory of
earlier conversation turns which may be stale.

---

## Decuple 00 — cyberia (meta: docs, assets, secrets, tests, scripts, iso)
Current known sub-layers: `01-docs`, `02-assets`, `03-treasure`, `05-tests`,
`06-scripts`, `08-iso`. Gaps at 00, 04, 07.
1. Ask: "Are 00, 04, and 07 intentionally reserved for something specific,
   or just unused gaps? If reserved, for what?"
2. Ask: "Does anything currently in `01-docs` (like `.agents/` workflow docs
   or the phase-task prompt docs) actually belong in a different decuple, or
   is meta/repo-tooling the right permanent home for all of it?"
3. Confirm final state for 00 before moving on.

## Decuple 10 — system (foundation, users, hardware)
1. Ask: "Is this decuple's current sub-structure (foundation/users/hardware)
   complete, or do you anticipate needing more categories here — e.g. a
   dedicated `boot`/`greeter` sub-layer, especially if decuple 30's old
   theming content relocates here per earlier discussion?"
2. If the user confirmed earlier that boot/greeter theming should move from
   the old 30-theming into 10-system, confirm the exact sub-layer number and
   name now.
3. Confirm final state for 10 before moving on.

## Decuple 20 — services (networking, ai, data, monitoring)
1. Present the specific known problem: `22-ai/25-harness-control` currently
   reuses the digit "25" at depth 3 in dash-notation, colliding visually
   with the sibling top-level `25-data`. Ask: "Fix this now using dot-
   notation (`22-2-harness-control` or similar), or hold it for the
   containers/virtualization decision below since that may restructure
   22-ai's internal layout anyway?"
2. Ask: "If containers/VMs move to their own decuple (see decuple 30 below),
   does anything currently in 20-services (e.g. Podman/oci-containers
   config for Langfuse) move out with them, or does 20-services keep
   'runs as a service regardless of container tech' and only the
   container-orchestration mechanism itself moves?"
3. Ask: "Does 22-ai need more room reserved now for growth (inference
   servers, harness-control, agent-uis are already nested there, separate
   from 70-agents' agent-definition concern) — reserve named-but-empty
   slots, or leave for a future pass?"
4. Confirm final state for 20 before moving on.

## Decuple 30 — currently vacated (old theming content relocating to 10/40)
Three candidates were raised across this conversation: (a) containers/VMs
(Podman, extra-container, MicroVMs) as their own isolation-concern decuple,
(b) desktop environments/shells/dotfiles if the user decides against putting
these under 40, (c) overflow relief for decuple 20.
1. Ask directly: "Which of these three should 30 become, or is there a
   fourth option?" Do not proceed on anything less than one clear answer.
2. If containers/VMs: ask for the exact sub-layer breakdown (e.g.
   `31-podman`, `32-extra-container`, `33-microvm`) and confirm what, if
   anything, moves out of 20-services as a result (ties back to decuple 20
   question 2 — resolve consistently with that answer).
3. Confirm final state for 30 before moving on.

## Decuple 40 — desktop (compositors + shells, two-axis model)
Agreed two-axis model: compositors (Hyprland, Niri, Sway, KDE6, Gnome) as
one numbered sub-range, shells/rice (Noctalia, End-4, Hyde, DMS) as a second
sub-range. The user's latest preference was shells starting at 45.
1. Confirm explicitly: "Compositors 41-44, shells 45-48 — still correct, or
   has this changed since we last discussed it?"
2. Ask: "Is this the complete list of compositors/shells you want numbered
   slots for, or should room be reserved for others you might add later
   (e.g. a different Wayland compositor, a different rice project)?"
3. Ask: "Does the assertion-based validity constraint (e.g. DMS/End-4/Hyde
   only valid when compositor=Hyprland; Noctalia valid on Hyprland or Niri)
   match your actual understanding of which shells work on which
   compositors? Confirm or correct before this becomes the option schema."
4. Confirm final state for 40 before moving on.

## Decuple 50 — cli/tui programs
1. Flag directly: "`gedit.nix` currently lives under `52-editors` in this
   decuple, but gedit is a GUI editor, not CLI/TUI — this looks like a
   miscategorization. Move it to decuple 60?"
2. Ask: "Do you want room pre-reserved now for categories you don't have
   yet — terminal multiplexers, CLI monitoring tools (htop/btop-style,
   distinct from the services-monitoring stack in 20), etc. — or leave that
   for later?"
3. Confirm final state for 50 before moving on.

## Decuple 60 — gui programs
1. Note current thinness: only `62-media` confirmed so far. Ask: "Does
   `vicinae.nix` (currently under `40-desktop/44-de-frameworks`) move here
   as a program rather than desktop infrastructure, per earlier discussion?"
2. Ask: "Reserve room now for productivity/creative/communication
   categories, or leave for later?"
3. Confirm final state for 60 before moving on.

## Decuple 70 — agents (already substantially agreed)
Agreed restructure: 71-agents, 72-skills, 73-mcp-servers, 74-memory,
75-tools, 76-sandbox, 77-telemetry, 78-gui, 79-orchestrator.
1. Ask: "MCP transports (stdio, sse) under 73 — plain names (`73-mcp-
   servers/stdio/`) or dot-notation (`73.1`/`73.2`)? Both are valid under
   the standing depth rule; this is purely your preference for how you'd
   reference them verbally/in search."
2. Ask: "If decuple 80 gets vacated (see below), do you want 70-agents to
   claim 70-89 as a double-wide band given how central this domain is, or
   keep it strictly at 70-79?"
3. Confirm final state for 70 before moving on.

## Decuple 80 — lib (currently near-empty)
Two candidates: (a) leave mostly reserved as headroom for whichever concern
needs it most later; (b) actively populate with "activities" — a concept
the user has referenced but not yet formally defined.
1. Ask directly: "Define 'activities' precisely — how is this different
   from what layer 90 (tags/profiles) already does? Give a concrete example
   of an activity that isn't already expressible as a tag." Do not proceed
   until you have a real definition, not just the word.
2. Ask: "Separately — framework plumbing (`mkDendriticModule`, `all-
   layers.nix`) could move to an unnumbered dotfile-prefixed directory like
   `.agents/` or `.supergraph/` instead of consuming a numbered decuple.
   Do you want this, and does it change your answer to question 1?"
3. Confirm final state for 80 before moving on — this may be "reserved,
   populate later" and that's a valid final answer, not a deferral.

## Decuple 90 — profiles/tags (needs to be filled out, not renumbered)
This decuple's NUMBER isn't in question — its CONTENT is underbuilt, and the
user flagged a possible regression here (enable-logic deleted from
`machines/*` during the dendritic migration without being relocated here).
1. Confirm: "Has the profiles/machines regression audit (from the earlier
   compat-fixes prompt) been completed and its findings resolved? If not,
   that should happen before finishing 90's structure, since you can't know
   what's missing here until that audit reports back."
2. If decuple 80 became "activities" per that decision: ask how activities
   and tags/profiles relate structurally — does an activity reference one or
   more tags, or are they independent axes a machine combines?
3. Confirm final state for 90 before moving on.

---

## After all ten decuples are resolved
1. Produce a complete draft `layers/NUMBERING.md` reflecting every decision
   made above, including explicit "reserved, not yet populated" notes for
   any decuple where the user chose that, and a philosophy section stating
   the nouns/verbs distinction and the depth-notation rule.
2. Produce a full file-move manifest: every file that would move, old path
   → new path, and every `layers.layer-NN.*` option reference across the
   whole repo that would need updating as a result — search exhaustively,
   don't estimate.
3. Present both to the user and ask explicitly: "Type 'apply' to execute
   this exact plan, or tell me what to change." Do not execute on anything
   less explicit than that literal word.
4. Only after receiving "apply": execute all moves in one atomic PR, run
   `nix flake check` before opening it, and include the before/after
   `NUMBERING.md` diff in the PR description.
5. After merge, update every doc that referenced old numbering (cross-check
   against the list flagged during the earlier docs-polish pass).
