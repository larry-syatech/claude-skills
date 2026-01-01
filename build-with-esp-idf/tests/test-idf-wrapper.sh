#!/usr/bin/env bash
#
# Test Suite for idf.sh wrapper script
#
# Tests that the idf-wrapper-template.sh correctly:
# 1. Auto-detects ESP-IDF paths
# 2. Validates installation prerequisites
# 3. Handles missing files gracefully
# 4. Provides helpful error messages
#
# Usage:
#   ./tests/test-idf-wrapper.sh

set -e

# Test framework variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TEMPLATE_PATH="$PROJECT_ROOT/scripts/idf-wrapper-template.sh"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Create temporary test directory
TEST_TEMP_DIR="/tmp/idf-wrapper-test-$$"
mkdir -p "$TEST_TEMP_DIR"

# Cleanup function
cleanup() {
    if [ -d "$TEST_TEMP_DIR" ]; then
        rm -rf "$TEST_TEMP_DIR"
    fi
}
trap cleanup EXIT

# Test framework functions
test_start() {
    TESTS_RUN=$((TESTS_RUN + 1))
    echo ""
    echo -e "${BLUE}Test $TESTS_RUN: $1${NC}"
    echo "----------------------------------------"
}

test_pass() {
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo -e "${GREEN}✓ PASS${NC}: $1"
}

test_fail() {
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo -e "${RED}✗ FAIL${NC}: $1"
}

test_info() {
    echo -e "  ${YELLOW}INFO${NC}: $1"
}

# ============================================================================
# Test 1: Template file exists and is valid bash
# ============================================================================
test_start "Template file exists and is valid bash"

if [ ! -f "$TEMPLATE_PATH" ]; then
    test_fail "Template file not found at: $TEMPLATE_PATH"
else
    test_pass "Template file exists"

    # Check if it's a bash script
    if head -n 1 "$TEMPLATE_PATH" | grep -q "^#!/usr/bin/env bash"; then
        test_pass "Has correct shebang (#!/usr/bin/env bash)"
    else
        test_fail "Missing or incorrect shebang"
    fi

    # Check syntax
    if bash -n "$TEMPLATE_PATH" 2>/dev/null; then
        test_pass "Bash syntax is valid"
    else
        test_fail "Bash syntax error detected"
    fi
fi

# ============================================================================
# Test 2: Auto-detection logic for IDF_PATH
# ============================================================================
test_start "IDF_PATH auto-detection logic"

if grep -q "Auto-detect ESP-IDF installation path" "$TEMPLATE_PATH"; then
    test_pass "Template includes auto-detection logic"
else
    test_fail "Auto-detection logic not found in template"
fi

# Check that it checks IDF_PATH environment variable first
if grep -q 'if \[ -n "\$IDF_PATH" \]' "$TEMPLATE_PATH"; then
    test_pass "Checks IDF_PATH environment variable"
else
    test_fail "Does not check IDF_PATH environment variable"
fi

# Check for default fallback path
if grep -q "~/esp/esp-idf\|/esp/esp-idf" "$TEMPLATE_PATH"; then
    test_pass "Has fallback to default ESP-IDF path"
else
    test_fail "Missing fallback path logic"
fi

# ============================================================================
# Test 3: export.ps1 validation
# ============================================================================
test_start "export.ps1 existence check"

if grep -q "Verify export.ps1 exists" "$TEMPLATE_PATH"; then
    test_pass "Template includes export.ps1 validation"
else
    test_fail "Missing export.ps1 validation"
fi

if grep -q 'if \[ ! -f "\$UNIX_IDF_PATH/export.ps1" \]' "$TEMPLATE_PATH"; then
    test_pass "Checks for export.ps1 file existence"
else
    test_fail "Does not check export.ps1 existence"
fi

if grep -q "export.ps1 not found" "$TEMPLATE_PATH"; then
    test_pass "Provides error message if export.ps1 missing"
else
    test_fail "Missing error message for export.ps1"
fi

# ============================================================================
# Test 4: install.ps1 prerequisite checks
# ============================================================================
test_start "install.ps1 prerequisite validation"

if grep -q "idf-env.json" "$TEMPLATE_PATH"; then
    test_pass "Checks for idf-env.json marker file"
else
    test_fail "Does not check for idf-env.json"
fi

if grep -q "python_env" "$TEMPLATE_PATH"; then
    test_pass "Checks for Python virtual environment"
else
    test_fail "Does not check for Python virtual environment"
fi

if grep -q "IDF_TOOLS_PATH" "$TEMPLATE_PATH"; then
    test_pass "Respects IDF_TOOLS_PATH environment variable"
else
    test_fail "Does not check IDF_TOOLS_PATH"
fi

# Check for tools directory validation
if grep -q "TOOLS_DIR" "$TEMPLATE_PATH"; then
    test_pass "Validates tools directory existence"
else
    test_fail "Does not validate tools directory"
fi

# ============================================================================
# Test 5: Error messages are helpful
# ============================================================================
test_start "Error messages provide actionable guidance"

# Check for install.ps1 error message
if grep -q "install.ps1" "$TEMPLATE_PATH"; then
    test_pass "Mentions install.ps1 in error messages"
else
    test_fail "Does not mention install.ps1 in errors"
fi

# Check for PowerShell command examples
if grep -q "\.\\\\install.ps1\|install.ps1" "$TEMPLATE_PATH"; then
    test_pass "Provides example install.ps1 command"
else
    test_fail "Missing example install.ps1 command"
fi

# Check for common installation paths
if grep -q "Common installation paths\|Expected location" "$TEMPLATE_PATH"; then
    test_pass "Lists common/expected paths in errors"
else
    test_fail "Does not provide path guidance"
fi

# ============================================================================
# Test 6: MSYS environment variable cleanup
# ============================================================================
test_start "MSYS environment variable removal"

MSYS_VARS=(
    "MSYSTEM"
    "MINGW_PREFIX"
    "MSYSTEM_PREFIX"
    "MSYSTEM_CHOST"
    "MSYSTEM_CARCH"
)

ALL_FOUND=true
for var in "${MSYS_VARS[@]}"; do
    if grep -q "Remove-Item env:$var" "$TEMPLATE_PATH"; then
        test_info "Removes $var"
    else
        test_fail "Does not remove $var"
        ALL_FOUND=false
    fi
done

if [ "$ALL_FOUND" = true ]; then
    test_pass "Removes all critical MSYS environment variables"
fi

# ============================================================================
# Test 7: PowerShell invocation
# ============================================================================
test_start "PowerShell invocation is correct"

if grep -q "powershell.exe" "$TEMPLATE_PATH"; then
    test_pass "Uses powershell.exe for execution"
else
    test_fail "Does not invoke PowerShell"
fi

if grep -q "\-NoProfile" "$TEMPLATE_PATH"; then
    test_pass "Uses -NoProfile flag for faster startup"
else
    test_fail "Missing -NoProfile optimization"
fi

if grep -q "\-Command" "$TEMPLATE_PATH"; then
    test_pass "Uses -Command parameter"
else
    test_fail "Missing -Command parameter"
fi

# ============================================================================
# Test 8: Path conversion
# ============================================================================
test_start "Path conversion (Unix to Windows)"

if grep -q "cygpath -w" "$TEMPLATE_PATH"; then
    test_pass "Uses cygpath for path conversion"
else
    test_fail "Does not use cygpath for path conversion"
fi

if grep -q "WIN_PROJECT_DIR\|WIN_IDF_PATH" "$TEMPLATE_PATH"; then
    test_pass "Creates Windows path variables"
else
    test_fail "Missing Windows path variables"
fi

# ============================================================================
# Test 9: Command passthrough
# ============================================================================
test_start "idf.py command passthrough"

if grep -q 'idf.py \$\*' "$TEMPLATE_PATH"; then
    test_pass "Passes all arguments to idf.py using \$*"
else
    test_fail "Does not properly pass arguments to idf.py"
fi

if grep -q 'IDF_COMMAND=' "$TEMPLATE_PATH"; then
    test_pass "Constructs IDF_COMMAND variable"
else
    test_fail "Missing IDF_COMMAND construction"
fi

# ============================================================================
# Test 10: Functional test with mock environment
# ============================================================================
test_start "Functional test with mocked environment"

# Create a mock ESP-IDF structure
MOCK_IDF_DIR="$TEST_TEMP_DIR/mock-esp-idf"
mkdir -p "$MOCK_IDF_DIR"

# Create mock export.ps1
cat > "$MOCK_IDF_DIR/export.ps1" << 'EOF'
# Mock export.ps1
Write-Host "ESP-IDF mock export"
EOF

# Create mock .espressif structure
MOCK_ESPRESSIF="$TEST_TEMP_DIR/.espressif"
mkdir -p "$MOCK_ESPRESSIF/python_env/idf5.5_py3.11_env"
mkdir -p "$MOCK_ESPRESSIF/tools"

# Create mock idf-env.json
cat > "$MOCK_ESPRESSIF/idf-env.json" << 'EOF'
{
  "features": ["core"],
  "targets": ["esp32", "esp32c6"]
}
EOF

# Create a test idf.sh from template
TEST_IDF_SH="$TEST_TEMP_DIR/idf.sh"
cp "$TEMPLATE_PATH" "$TEST_IDF_SH"
chmod +x "$TEST_IDF_SH"

test_pass "Created mock ESP-IDF environment"
test_info "Mock IDF at: $MOCK_IDF_DIR"
test_info "Mock .espressif at: $MOCK_ESPRESSIF"

# Test with IDF_PATH set
export IDF_PATH="$MOCK_IDF_DIR"
export IDF_TOOLS_PATH="$MOCK_ESPRESSIF"

# Extract the validation logic and test it
if bash -c "
    source '$TEST_IDF_SH'
    exit 0
" 2>&1 | grep -q "export.ps1 not found\|idf-env.json not found\|Python virtual environment not found"; then
    test_fail "Validation failed with properly configured mock environment"
else
    test_pass "Validation passes with properly configured environment"
fi

# Test with missing idf-env.json
rm -f "$MOCK_ESPRESSIF/idf-env.json"

if bash "$TEST_IDF_SH" --version 2>&1 | grep -q "idf-env.json not found"; then
    test_pass "Correctly detects missing idf-env.json"
else
    test_fail "Does not detect missing idf-env.json"
fi

# Restore for next test
cat > "$MOCK_ESPRESSIF/idf-env.json" << 'EOF'
{"features": ["core"], "targets": ["esp32"]}
EOF

# Test with missing python_env
rm -rf "$MOCK_ESPRESSIF/python_env"

if bash "$TEST_IDF_SH" --version 2>&1 | grep -q "Python virtual environment not found"; then
    test_pass "Correctly detects missing Python environment"
else
    test_fail "Does not detect missing Python environment"
fi

# ============================================================================
# Test 11: Template documentation
# ============================================================================
test_start "Template includes documentation"

# Check for header comments
if head -n 20 "$TEMPLATE_PATH" | grep -q "ESP-IDF wrapper"; then
    test_pass "Has descriptive header comment"
else
    test_fail "Missing header documentation"
fi

# Check for usage examples
if grep -q "Usage:" "$TEMPLATE_PATH"; then
    test_pass "Includes usage examples"
else
    test_fail "Missing usage examples"
fi

# ============================================================================
# Test Results Summary
# ============================================================================
echo ""
echo "=========================================="
echo "Test Results Summary"
echo "=========================================="
echo -e "${BLUE}Tests run:${NC}     $TESTS_RUN"
echo -e "${GREEN}Tests passed:${NC}  $TESTS_PASSED"
echo -e "${RED}Tests failed:${NC}  $TESTS_FAILED"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All tests passed!${NC}"
    echo ""
    echo "The idf-wrapper-template.sh is correctly configured with:"
    echo "  • Auto-detection of ESP-IDF installation paths"
    echo "  • Validation of install.ps1 prerequisites"
    echo "  • MSYS environment variable cleanup"
    echo "  • Helpful error messages with actionable guidance"
    echo "  • Proper PowerShell invocation and path conversion"
    exit 0
else
    echo -e "${RED}✗ Some tests failed${NC}"
    echo ""
    echo "Please review the failures above and update the template."
    exit 1
fi
