#!/usr/bin/env bash
# Test script for scripts/setup-persistence.sh

# set -e removed to handle expected failures manually if needed,
# but we will use subshells or explicit checks.

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

passed=0
failed=0

test_pass() {
  echo -e "${GREEN}✓ PASS${NC}: $1"
  ((passed++))
}

test_fail() {
  echo -e "${RED}✗ FAIL${NC}: $1"
  ((failed++))
}

# Create a temporary directory for our tests
TEST_ROOT=$(mktemp -d)
trap 'rm -rf "$TEST_ROOT"' EXIT

# Mock HOME directory
MOCK_HOME="$TEST_ROOT/home/testuser"
mkdir -p "$MOCK_HOME/.local/share/noctalia"
echo "test data" >"$MOCK_HOME/.local/share/noctalia/data.txt"

# Create a mock bin directory
MOCK_BIN="$TEST_ROOT/bin"
mkdir -p "$MOCK_BIN"

# Mock sudo: just execute the command
cat >"$MOCK_BIN/sudo" <<EOF
#!/usr/bin/env bash
"\$@"
EOF
chmod +x "$MOCK_BIN/sudo"

# Mock chown: just do nothing (avoids "invalid user" error)
cat >"$MOCK_BIN/chown" <<EOF
#!/usr/bin/env bash
exit 0
EOF
chmod +x "$MOCK_BIN/chown"

# Add mock bin to path
export PATH="$MOCK_BIN:$PATH"

# Test 1: Successful execution with custom values
echo "--- Test 1: Successful execution with custom values ---"
(
  export TARGET_USER="testuser"
  export PERSIST_DIR="$TEST_ROOT/persist"
  export HOME="$MOCK_HOME"
  bash scripts/setup-persistence.sh
)
STATUS=$?

if [ $STATUS -eq 0 ]; then
  TARGET_USER="testuser"
  PERSIST_DIR="$TEST_ROOT/persist"
  # Verify directories were created
  if [ -d "$PERSIST_DIR/home/$TARGET_USER/.local/share/noctalia" ] &&
    [ -d "$PERSIST_DIR/home/$TARGET_USER/.cache/noctalia" ] &&
    [ -d "$PERSIST_DIR/etc/libvirt" ]; then
    test_pass "Persistence directories created correctly"
  else
    test_fail "Persistence directories NOT created correctly"
  fi

  # Verify file copy
  if [ -f "$PERSIST_DIR/home/$TARGET_USER/.local/share/noctalia/data.txt" ]; then
    test_pass "Data copied successfully"
  else
    test_fail "Data NOT copied"
  fi
else
  test_fail "Script failed to execute (exit code $STATUS)"
fi

# Test 2: Failure when TARGET_USER is empty
echo ""
echo "--- Test 2: Failure when TARGET_USER is empty ---"
(
  unset TARGET_USER
  export TARGET_USER=""
  export PERSIST_DIR="$TEST_ROOT/persist2"
  export HOME="$MOCK_HOME"
  bash scripts/setup-persistence.sh >/dev/null 2>&1
)
STATUS=$?

if [ $STATUS -ne 0 ]; then
  test_pass "Script correctly failed when TARGET_USER is empty (exit code $STATUS)"
else
  test_fail "Script DID NOT fail when TARGET_USER is empty (exit code $STATUS)"
fi

echo ""
echo "================================"
echo "Results: ${GREEN}$passed passed${NC}, ${RED}$failed failed${NC}"
echo "================================"

if [ $failed -gt 0 ]; then
  exit 1
fi
