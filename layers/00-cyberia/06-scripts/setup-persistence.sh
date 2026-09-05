#!/usr/bin/env bash
# Pre-build setup for persistence directories
# Part of Grandlix-Gang system refactoring

set -e

# Configuration with defaults
# Use a temporary variable to check if it's explicitly set to empty
_TARGET_USER="${TARGET_USER-UNDEFINED}"
TARGET_USER="${TARGET_USER:-t0psh31f}"
PERSIST_DIR="${PERSIST_DIR:-/persist}"

echo "🚀 Setting up persistence directories for Noctalia and libvirt..."
echo "👤 Target User: $TARGET_USER"
echo "📂 Persist Dir: $PERSIST_DIR"

# Validation
if [ "$_TARGET_USER" = "" ]; then
  echo "❌ Error: TARGET_USER environment variable is explicitly set to empty."
  exit 1
fi

if [ -z "$TARGET_USER" ]; then
  echo "❌ Error: TARGET_USER is empty."
  exit 1
fi

if [ ! -d "$PERSIST_DIR" ]; then
  echo "⚠️  Warning: $PERSIST_DIR does not exist. Attempting to create it..."
  sudo mkdir -p "$PERSIST_DIR" || {
    echo "❌ Error: Could not create $PERSIST_DIR"
    exit 1
  }
fi

# Create Noctalia persistence directories
echo "📁 Creating Noctalia persistence directories..."
sudo mkdir -p "$PERSIST_DIR/home/$TARGET_USER/.local/share/noctalia"
sudo mkdir -p "$PERSIST_DIR/home/$TARGET_USER/.cache/noctalia"
sudo mkdir -p "$PERSIST_DIR/etc/libvirt"

# Copy existing Noctalia data if it exists
if [ -d "$HOME/.local/share/noctalia" ]; then
  echo "📦 Copying existing Noctalia data..."
  sudo cp -rv "$HOME/.local/share/noctalia/"* "$PERSIST_DIR/home/$TARGET_USER/.local/share/noctalia/" 2>/dev/null || true
fi

if [ -d "$HOME/.cache/noctalia" ]; then
  echo "📦 Copying existing Noctalia cache..."
  sudo cp -rv "$HOME/.cache/noctalia/"* "$PERSIST_DIR/home/$TARGET_USER/.cache/noctalia/" 2>/dev/null || true
fi

# Fix ownership
echo "🔧 Fixing ownership..."
sudo chown -R "$TARGET_USER:users" "$PERSIST_DIR/home/$TARGET_USER/.local"
sudo chown -R "$TARGET_USER:users" "$PERSIST_DIR/home/$TARGET_USER/.cache"

# Verify
echo ""
echo "✅ Verifying directories..."
echo "---"
ls -la "$PERSIST_DIR/home/$TARGET_USER/.local/share/" 2>/dev/null | grep noctalia || echo "⚠️  .local/share/noctalia not found"
ls -la "$PERSIST_DIR/home/$TARGET_USER/.cache/" 2>/dev/null | grep noctalia || echo "⚠️  .cache/noctalia not found"
ls -la "$PERSIST_DIR/etc/" 2>/dev/null | grep libvirt || echo "⚠️  /etc/libvirt not found"
echo "---"
echo ""
echo "✅ Pre-build setup complete!"
echo ""
echo "Next steps:"
echo "  1. cd ~/Clan/Grandlix-Gang"
echo "  2. sudo nixos-rebuild dry-build --flake .#grandlixos"
echo "  3. sudo nixos-rebuild switch --flake .#grandlixos"
echo "  4. home-manager switch --flake .#$TARGET_USER@grandlixos"
