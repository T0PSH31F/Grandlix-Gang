#!/usr/bin/env bash
# Integration test for scripts/clan-validate.sh security fix

# Setup a temporary directory for our mock environment
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

# Create mock binaries
mkdir -p "$TMP_DIR/bin"
cat <<EOF > "$TMP_DIR/bin/nix"
#!/usr/bin/env bash
echo "mock nix \$@"
exit 0
EOF
cat <<EOF > "$TMP_DIR/bin/clan"
#!/usr/bin/env bash
echo "mock clan \$@"
exit 0
EOF
chmod +x "$TMP_DIR/bin/nix" "$TMP_DIR/bin/clan"

# Set up the environment to use our mocks and ensure bash is available
export PATH="$TMP_DIR/bin:/usr/bin:/bin"

# Run the validation script and capture output
# We expect it to succeed because our mocks return 0
OUTPUT=$(bash scripts/clan-validate.sh)
RET=$?

echo "$OUTPUT"

if [ $RET -eq 0 ] && echo "$OUTPUT" | grep -q "Nix flake check completed successfully"; then
    echo "SUCCESS: Validation script ran correctly with the fix."
else
    echo "FAILURE: Validation script failed or produced unexpected output."
    exit 1
fi
