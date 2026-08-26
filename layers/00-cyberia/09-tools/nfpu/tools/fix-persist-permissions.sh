#!/usr/bin/env bash
# tools/fix-persist-permissions.sh
# Purpose: Align ownership and permissions of persistent state directories under /persist
# with the current NixOS system users/groups to resolve "Permission denied" errors.

set -euo pipefail

if [ "$EUID" -ne 0 ]; then
  echo "Error: This script must be run as root (with sudo)." >&2
  exit 1
fi

echo "=== Aligning persistent state directory ownership ==="

fix_perms() {
  local dir="$1"
  local user="$2"
  local group="$3"
  local mode="$4"

  if [ -d "$dir" ]; then
    # Verify user exists, fallback to root
    if ! id -u "$user" >/dev/null 2>&1; then
      echo "Warning: User '$user' does not exist. Falling back to 'root'."
      user="root"
    fi
    # Verify group exists, fallback to root
    if ! getent group "$group" >/dev/null 2>&1; then
      echo "Warning: Group '$group' does not exist. Falling back to 'root'."
      group="root"
    fi

    echo "Adjusting: $dir -> $user:$group ($mode)"
    chown -R "$user:$group" "$dir"
    chmod -R u+rwX,g+rX,o-rwx "$dir" # Ensure owner can read/write, group can read, others nothing
    # Also apply the specific master directory mode if provided
    chmod "$mode" "$dir"
  else
    echo "Skipping:  $dir (does not exist)"
  fi
}

# Fix permissions on /persist/var/lib directories
fix_perms "/persist/var/lib/AdGuardHome" "adguardhome" "adguardhome" "0700"
fix_perms "/persist/var/lib/filebrowser" "filebrowser" "filebrowser" "0700"
fix_perms "/persist/var/lib/ollama" "ollama" "ollama" "0750"
fix_perms "/persist/var/lib/qdrant" "qdrant" "qdrant" "0750"
fix_perms "/persist/var/lib/sillytavern" "sillytavern" "sillytavern" "0755"
fix_perms "/persist/var/lib/headscale" "headscale" "headscale" "0750"
fix_perms "/persist/var/lib/vaultwarden" "vaultwarden" "vaultwarden" "0700"
fix_perms "/persist/var/vaultwarden-backup" "vaultwarden" "vaultwarden" "0700"
fix_perms "/persist/var/lib/nextjs-ollama-llm-ui" "nextjs-ollama-llm-ui" "nextjs-ollama-llm-ui" "0750"
fix_perms "/persist/var/lib/chromadb" "chromadb" "chromadb" "0750"
fix_perms "/persist/var/lib/nextcloud" "nextcloud" "nextcloud" "0750"
fix_perms "/persist/var/lib/n8n" "n8n" "n8n" "0700"

echo "=== Restarting impacted services ==="
systemctl restart adguardhome.service \
  filebrowser.service \
  ollama.service \
  qdrant.service \
  sillytavern.service \
  headscale.service \
  backup-vaultwarden.service \
  nextjs-ollama-llm-ui.service \
  chromadb.service \
  phpfpm-nextcloud.service \
  n8n.service \
  nginx.service \
  caddy.service || true

echo "=== Done ==="
