#!/usr/bin/env bash
# fs-diff.sh - Compare current @root with @root-blank to find unpersisted files
# Ref: https://mt-caret.github.io/blog/posts/2020-06-29-optin-state.html

set -euo pipefail

# Check if running as root
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root (or with sudo)"
  exit 1
fi

MOUNT_DIR=$(mktemp -d)
trap 'umount "$MOUNT_DIR" && rm -rf "$MOUNT_DIR"' EXIT

# Find the device for /
ROOT_DEV=$(df / | tail -1 | awk '{print $1}')
# If it's a mapper device, we want it
# If it's a btrfs subvolume, we need the parent device

# Mount the btrfs root (subvolid=5)
mount -o subvolid=5 "$ROOT_DEV" "$MOUNT_DIR"

OLD_TRANSID=$(btrfs subvolume find-new "$MOUNT_DIR/@root-blank" 9999999)
OLD_TRANSID=${OLD_TRANSID#transid marker was }

echo "--- Files changed since @root-blank snapshot ---"
btrfs subvolume find-new "$MOUNT_DIR/@root" "$OLD_TRANSID" |
  sed '$d' |
  cut -f17- -d' ' |
  sort |
  uniq |
  while read -r path; do
    full_path="/$path"
    if [ -L "$full_path" ]; then
      : # Symbolic link, likely handled by Nix
    elif [ -d "$full_path" ]; then
      : # Directory, ignore
    else
      echo "$full_path"
    fi
  done
