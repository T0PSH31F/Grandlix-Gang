# Prompt for Antigravity/Hermes: CRITICAL Performance Investigation — No Early Exit

Repo: github.com/T0PSH31F/NFP. This is a P0 issue actively harming the user's
workflow. Prior attempts have declared "fixed" prematurely or given up early.
This prompt exists specifically to prevent that pattern. Read the hard rules
below before doing anything else.

## Hard rules — violating these invalidates the entire investigation
1. **Never declare something fixed based on a single point-in-time check.**
   Every fix must be verified by holding a defined metric below a defined
   threshold for a **minimum 2-hour continuous session** under the user's
   actual normal workflow (terminal + Antigravity + browser, nothing else),
   not a synthetic test. "Looks better for a minute" is not evidence.
2. **Do not conflate the two symptom clusters below.** They may share a
   cause, but treat them as separate hypotheses until evidence says
   otherwise. Investigate both in parallel, report on both separately.
3. **Do not stop at the first plausible-looking cause.** If you find *a*
   contributing factor, keep investigating for others before reporting
   success — this system has a documented history of one fix "helping
   slightly" while the underlying problem returns (see `agent-progress.md`'s
   earlier `oom-kill-mitigations` entry, which mitigated symptoms via
   earlyoom tuning without ever identifying why memory pressure was high
   enough to need that mitigation in the first place).
4. **Run this investigation on BOTH machines** (`z0r0` and `luffy` — laptop
   and desktop). The user reports the same symptoms on both, on different
   hardware, which strongly suggests a shared config/service cause rather
   than a hardware-specific one. Diff your findings between the two.
5. **Report every step's raw output**, not just your conclusion. The user
   needs to be able to verify your reasoning, not just trust a summary.

## Cluster A — Sustained high RAM (13.2GB+ idle, 100% on desktop)

### A1. Establish true baseline first, not incremental disabling
Booting into a previous generation and testing at each layer removed is more
reliable than disabling services from the currently-running state, since a
currently-running process may already hold leaked memory that a later
`systemctl stop` doesn't release, making the test look like "no difference"
even if the service WAS the cause. Boot into a minimal-tag generation (or
build one) with only `10-system` + bare desktop enabled, nothing from
`20-services` or `70-agents`, and measure baseline RAM after a clean boot
with only a terminal open. Record this number — it's the true floor.

### A2. Check the impermanence tmpfs-root hypothesis specifically
If root (`/`) is a tmpfs (standard impermanence pattern), any data written
to non-persisted paths lives literally in RAM, and "disabling services"
would never fix this since it's about *data location*, not which process is
running.
1. Run `df -h /` and `mount | grep 'on / '` on both machines — confirm
   whether `/` is tmpfs and how large it currently is.
2. If tmpfs: run `du -sh /* 2>/dev/null | sort -rh | head -20` to find what's
   actually occupying it. Pay specific attention to `/tmp`, `/var/log`,
   `/var/tmp`, `/root`, and any Nix build scratch directories that may not
   be going where expected.
3. Cross-reference against the impermanence persistence list — confirm
   nothing large is writing to a path that was supposed to be persisted but
   isn't actually bind-mounted correctly (a misconfigured persistence entry
   would silently redirect writes into tmpfs instead of disk).
4. This is a high-priority lead — investigate it before broader service
   auditing, since it would explain RAM growth independent of which
   services are enabled.

### A3. Real leak detection via repeated PSS sampling, not one snapshot
1. Run `smem -t -k -c "pid user pss command" | head -30` at four points:
   immediately after login, +30 min, +2 hours, +4 hours — same session,
   same workload (terminal + Antigravity + browser only, matching the
   user's actual usage).
2. Identify any single process whose PSS **grows monotonically** across
   these samples — that's a real leak, distinct from a high-but-stable
   baseline (which is over-provisioning, a different problem with a
   different fix).
3. Specifically profile Noctalia and Antigravity's own RSS/PSS growth over
   this window — both are long-running GUI processes the user keeps open
   continuously, and either is a plausible leak candidate given session
   length.

### A4. Systemd/service audit — verify disabling actually took effect
1. Run `systemctl list-units --state=running --no-legend` and cross-check
   every running unit against current `layers.*.enable` flags in the
   evaluated config — find any unit still running that should be disabled
   per config (stale unit from before a rebuild, or a tag/profile
   re-enabling something the user thought they turned off).
2. Check specifically whether the "ai-server" tag (or whichever tag enables
   langfuse/postgres/brain-service/voice) is active on both machines' current
   profile — if so, that's likely a large chunk of the baseline by design,
   not a bug, and the user needs to know that explicitly rather than keep
   hunting for a "bug" that's actually "intended services running."
3. For genuinely disabled-but-still-running units found in step 1, determine
   why they didn't stop (lingering process, failed unit stop, or a
   dependency keeping it alive) and fix the actual mechanism, not just
   manually kill the process.

### A5. Swap/zram adequacy check
1. Confirm zram or swap configuration and size on both machines
   (`zramctl`, `swapon --show`, `free -h`).
2. If memory pressure is real (not just tmpfs data), inadequate swap turns
   pressure into either OOM kills or severe stutter (see Cluster B overlap
   below) rather than graceful degradation. Recommend a sizing fix if
   current swap/zram is clearly undersized relative to the 16GB systems.

## Cluster B — UI freezes, stutters, slow workspace switching, slow browser loads

### B1. Test the Intel PSR hypothesis (laptop, 13th-gen Intel iGPU)
This is a well-documented, still-active kernel bug (reported as recently as
February 2026 against kernel 6.19) causing exactly these symptoms —
stuttering, freezing, tearing — specifically on Intel iGPUs with Panel Self
Refresh enabled, and is a strong candidate independent of the RAM issue.
1. Check current kernel params: `cat /proc/cmdline | grep -o 'i915[^ ]*'`.
2. As a test (not a permanent fix yet), add `i915.enable_psr=0` to kernel
   params (via `boot.kernelParams` in the relevant machine config) and
   reboot. Run the user's normal workflow for the full 2-hour verification
   window from the hard rules above and report whether freezing/stuttering
   during workspace switches and program launches specifically improved.
3. If the laptop's chip supports the newer `xe` driver instead of `i915`,
   check whether switching drivers resolves it as an alternative to
   disabling PSR — check `lspci -nn | grep VGA` for the PCI ID and cross-
   reference against known `xe` driver support for that generation.
4. This is laptop-specific (desktop likely uses different graphics) — if
   this fixes laptop stutter but the desktop shows the same symptom, that
   confirms Cluster B has at least two independent causes, not one; keep
   investigating the desktop's case separately (check its actual GPU:
   discrete vs. integrated, driver in use).

### B2. Check for I/O-blocked processes during a freeze (rclone VFS hypothesis)
The user's repo already caps rclone VFS cache at 2GB per `agent-progress.md`,
implying rclone-related memory/IO pressure was already a known issue that
was mitigated, not root-caused.
1. During or immediately after a freeze event, run `ps aux | awk '$8 ~ /D/'`
   to find processes in uninterruptible-sleep (blocked on I/O) — this is
   the direct signature of a hung filesystem/network mount causing a UI
   freeze.
2. If rclone processes appear, check `rclone rc vfs/stats` (if the rc API is
   enabled) or rclone's own logs for timeout/retry patterns coinciding with
   freeze timestamps reported by the user.
3. If confirmed, determine whether the freezing path is one the desktop
   session touches during normal navigation (e.g. a rclone-mounted
   directory inside `$HOME` that a file picker or shell completion scans) —
   if so, that's the actual mechanism causing "freezes when switching
   workspaces/opening programs," not a generic slowness.

### B3. Cross-reference the known Noctalia+Intel Iris Xe bug already documented
in this repo's own `hypridle.nix` comment ("Broken pipe" crash on Alder Lake
when display wakes from DPMS). Confirm the laptop is actually 13th-gen
(Raptor Lake, not Alder Lake) — if the chip generation differs from what
that fix was written for, the existing hypridle mitigation may not fully
cover this hardware, and the crash-on-wake behavior described by the user
("crashes my desktop env... requiring reboot") may be a related-but-distinct
variant of the same underlying Intel iGPU/compositor interaction needing its
own fix, not something already covered.

### B4. Rule in/out memory pressure as a Cluster B contributor
Once Cluster A's true baseline (A1) is known, check whether stutter events
correlate in time with available-memory dropping below a critical threshold
(`vmstat 1` during a reproduction, watching `si`/`so` swap activity) — severe
memory pressure alone can produce freeze-like stutter via swap thrashing,
which would mean fixing Cluster A partially fixes Cluster B too. Don't
assume this either way — check the timestamps.

## Reporting requirements
1. A running log of every hypothesis tested, raw command output, and
   pass/fail against the 2-hour sustained-verification rule — not a
   cleaned-up summary presented only at the end.
2. Explicit statement of which causes were CONFIRMED (with evidence), which
   were RULED OUT (with evidence), and which remain UNRESOLVED after this
   pass — do not let "unresolved" quietly disappear from the final report.
3. If multiple causes are found (likely, given two symptom clusters), fix
   them in the order of highest-confidence/lowest-risk first, re-verifying
   the 2-hour window after each individual fix before moving to the next —
   changing multiple things at once makes it impossible to know which fix
   actually worked.
4. Do not close this out until the user has personally confirmed (not the
   agent's own measurement alone) that the system feels usable across a
   real work session.
