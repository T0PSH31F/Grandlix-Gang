# Password Policy — CRITICAL

## System Passwords

| User | Password | Notes |
|------|----------|-------|
| root | 5677 | NEVER change without explicit user permission |
| t0psh31f | 5677 | NEVER change without explicit user permission |

## Rules

1. **NEVER run `clan vars generate` with `--regenerate` on password generators** — it will overwrite with random passwords and lock the user out
2. **NEVER run `clan vars generate --fake-prompts`** — it generates random passwords
3. **If you need to set passwords**, use: `echo "5677" | clan vars set <machine> user-password-<user>/user-password`
4. **If you accidentally change a password**, fix it immediately with: `echo "5677" | sudo -S passwd <user>`
5. **Always verify passwords after deploy**: `echo "5677" | sudo -S whoami`

## Clan Vars Commands (SAFE)

```bash
# List vars (safe, read-only)
clan vars list z0r0

# Get a var value (safe, read-only)
clan vars get z0r0 user-password-t0psh31f/user-password

# Set a var value (safe, use for passwords)
echo "5677" | clan vars set z0r0 user-password-t0psh31f/user-password

# Generate vars (DANGEROUS - only for new machines, never for passwords)
clan vars generate z0r0 --generator openssh  # OK for SSH keys
clan vars generate z0r0 --generator user-password-t0psh31f  # NEVER do this
```

## Emergency Recovery

If locked out:
1. Boot from live USB
2. Mount the system: `cd ~/Clan/NFP && ./tools/mount-nfp.sh z0r0`
3. Chroot: `sudo nixos-enter --root /mnt`
4. Reset password: `passwd t0psh31f` (set to 5677)
5. Rebuild: `cd /persist/home/t0psh31f/Clan/NFP && nixos-rebuild boot --flake .#z0r0`
