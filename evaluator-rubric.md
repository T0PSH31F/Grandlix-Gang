# Evaluator Rubric

Score after implementation, before acceptance. 0 = absent, 1 = partial, 2 = complete.
A feature may only be marked `passing` with a total ≥ 8 and no category at 0.

| Category | Question | Score (0-2) | Notes |
| --- | --- | --- | --- |
| Correctness | Does `nix flake check` pass and does the behavior match the feature's specified behavior? | | |
| Verification | Was every command in the feature's `verification` list actually run and logged as evidence? | | |
| Convention | Correct layer, `layers.layer-XX` namespace, registered in the layer's `default.nix`? | | |
| Persistence | All runtime state declared under /persist (impermanence on); images digest-pinned? | | |
| Secrets | No hardcoded credentials; clan vars used? | | |
| Docs | ports.md / AGENTS.md / 01-docs updated if behavior changed? | | |
