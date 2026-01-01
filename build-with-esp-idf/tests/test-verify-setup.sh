#!/usr/bin/env bash
#
# Test Suite for verify-setup.sh script
#
# Tests that verify-setup.sh correctly:
# 1. Checks project structure
# 2. Validates idf.sh wrapper
# 3. Detects ESP-IDF installation
# 4. Verifies install.ps1 has been run
# 5. Provides helpful output
#
# Usage:
#   ./tests/test-verify-setup.sh

set -e

# Test framework variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
VERIFY_SCRIPT="$PROJECT_ROOT/scripts/verify-setup.sh"

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
TEST_TEMP_DIR="/tmp/verify-setup-test-$$"
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
# Test 1: Verify script exists and is valid
# ============================================================================
test_start "verify-setup.sh exists and is valid bash"

if [ ! -f "$VERIFY_SCRIPT" ]; then
    test_fail "verify-setup.sh not found at: $VERIFY_SCRIPT"
else
    test_pass "verify-setup.sh exists"

    # Check shebang
    if head -n 1 "$VERIFY_SCRIPT" | grep -q "^#!/usr/bin/env bash"; then
        test_pass "Has correct shebang"
    else
        test_fail "Missing or incorrect shebang"
    fi

    # Check syntax
    if bash -n "$VERIFY_SCRIPT" 2>/dev/null; then
        test_pass "Bash syntax is valid"
    else
        test_fail "Bash syntax error detected"
    fi

    # Check if executable
    if [ -x "$VERIFY_SCRIPT" ]; then
        test_pass "Script is executable"
    else
        test_fail "Script is not executable (needs chmod +x)"
    fi
fi

# ============================================================================
# Test 2: Project structure checks
# ============================================================================
test_start "Checks for ESP-IDF project structure"

# Check for CMakeLists.txt validation
if grep -q "CMakeLists.txt" "$VERIFY_SCRIPT"; then
    test_pass "Validates CMakeLists.txt existence"
else
    test_fail "Does not check for CMakeLists.txt"
fi

# Check for main directory validation
if grep -q "main/" "$VERIFY_SCRIPT" && grep -q "main/CMakeLists.txt" "$VERIFY_SCRIPT"; then
    test_pass "Validates main/ directory and contents"
else
    test_fail "Does not properly check main/ directory"
fi

# Check for main source files
if grep -q "main.c\|main.cpp" "$VERIFY_SCRIPT"; then
    test_pass "Checks for main source file (main.c or main.cpp)"
else
    test_fail "Does not check for main source files"
fi

# ============================================================================
# Test 3: idf.sh wrapper validation
# ============================================================================
test_start "Validates idf.sh wrapper script"

if grep -q "idf.sh" "$VERIFY_SCRIPT"; then
    test_pass "Checks for idf.sh wrapper"
else
    test_fail "Does not check for idf.sh"
fi

# Check for executable validation
if grep -q "\-x.*idf.sh" "$VERIFY_SCRIPT"; then
    test_pass "Validates idf.sh is executable"
else
    test_fail "Does not check if idf.sh is executable"
fi

# Check for auto-detection validation
if grep -q "Auto-detect" "$VERIFY_SCRIPT"; then
    test_pass "Checks if idf.sh uses auto-detection"
else
    test_fail "Does not validate auto-detection"
fi

# ============================================================================
# Test 4: ESP-IDF installation checks
# ============================================================================
test_start "Checks ESP-IDF installation"

# Check for IDF_PATH validation
if grep -q "IDF_PATH" "$VERIFY_SCRIPT"; then
    test_pass "Checks IDF_PATH environment variable"
else
    test_fail "Does not check IDF_PATH"
fi

# Check for export.ps1 validation
if grep -q "export.ps1" "$VERIFY_SCRIPT"; then
    test_pass "Validates export.ps1 existence"
else
    test_fail "Does not check for export.ps1"
fi

# ============================================================================
# Test 5: install.ps1 prerequisite checks
# ============================================================================
test_start "Validates install.ps1 has been run"

# Check for idf-env.json
if grep -q "idf-env.json" "$VERIFY_SCRIPT"; then
    test_pass "Checks for idf-env.json marker"
else
    test_fail "Does not check for idf-env.json"
fi

# Check for IDF_TOOLS_PATH
if grep -q "IDF_TOOLS_PATH" "$VERIFY_SCRIPT"; then
    test_pass "Respects IDF_TOOLS_PATH environment variable"
else
    test_fail "Does not check IDF_TOOLS_PATH"
fi

# Check for .espressif default path
if grep -q "\.espressif" "$VERIFY_SCRIPT"; then
    test_pass "Uses .espressif as default tools path"
else
    test_fail "Missing .espressif default path"
fi

# Check for python_env directory
if grep -q "python_env" "$VERIFY_SCRIPT"; then
    test_pass "Checks for Python virtual environment"
else
    test_fail "Does not check Python environment"
fi

# Check for tools directory
if grep -q "tools" "$VERIFY_SCRIPT" && grep -q "TOOLS_DIR" "$VERIFY_SCRIPT"; then
    test_pass "Checks for tools directory"
else
    test_fail "Does not check tools directory"
fi

# ============================================================================
# Test 6: Build directory validation
# ============================================================================
test_start "Checks build directory configuration"

if grep -q "build-claude" "$VERIFY_SCRIPT"; then
    test_pass "Checks for build-claude directory"
else
    test_fail "Does not check build-claude directory"
fi

if grep -q "CMakeCache.txt" "$VERIFY_SCRIPT"; then
    test_pass "Checks for CMake cache"
else
    test_fail "Does not check CMake cache"
fi

if grep -q "\.gitignore" "$VERIFY_SCRIPT"; then
    test_pass "Checks .gitignore configuration"
else
    test_fail "Does not check .gitignore"
fi

# ============================================================================
# Test 7: Documentation checks
# ============================================================================
test_start "Checks for project documentation"

if grep -q "CLAUDE.md" "$VERIFY_SCRIPT"; then
    test_pass "Checks for CLAUDE.md"
else
    test_fail "Does not check for CLAUDE.md"
fi

if grep -q "BUILD-CLAUDE-CODE.md" "$VERIFY_SCRIPT"; then
    test_pass "Checks for BUILD-CLAUDE-CODE.md"
else
    test_fail "Does not check for BUILD-CLAUDE-CODE.md"
fi

# ============================================================================
# Test 8: Functional test (idf.sh execution)
# ============================================================================
test_start "Tests idf.sh functionality"

if grep -q "idf.sh --version" "$VERIFY_SCRIPT"; then
    test_pass "Runs idf.sh --version test"
else
    test_fail "Does not test idf.sh execution"
fi

if grep -q "ESP-IDF" "$VERIFY_SCRIPT"; then
    test_pass "Checks for ESP-IDF version in output"
else
    test_fail "Does not validate ESP-IDF version output"
fi

# ============================================================================
# Test 9: Output formatting
# ============================================================================
test_start "Output is well-formatted and informative"

# Check for color codes
if grep -q "GREEN\|RED\|YELLOW" "$VERIFY_SCRIPT"; then
    test_pass "Uses color codes for output"
else
    test_fail "Does not use color codes"
fi

# Check for status symbols
if grep -q "✓\|✗\|⚠" "$VERIFY_SCRIPT"; then
    test_pass "Uses status symbols (✓/✗/⚠)"
else
    test_fail "Missing status symbols"
fi

# Check for summary section
if grep -q "Summary\|Verification Summary" "$VERIFY_SCRIPT"; then
    test_pass "Includes results summary"
else
    test_fail "Missing results summary"
fi

# Check for counters
if grep -q "TESTS_RUN\|SUCCESS\|ERRORS\|WARNINGS" "$VERIFY_SCRIPT"; then
    test_pass "Tracks test results with counters"
else
    test_fail "Does not track test results"
fi

# ============================================================================
# Test 10: Error messages and guidance
# ============================================================================
test_start "Provides helpful error messages"

# Check for quick fix guide
if grep -q "Quick fix\|Next steps\|To fix" "$VERIFY_SCRIPT"; then
    test_pass "Includes troubleshooting guidance"
else
    test_fail "Missing troubleshooting guidance"
fi

# Check for install.ps1 instructions
if grep -q "install.ps1" "$VERIFY_SCRIPT"; then
    test_pass "Provides install.ps1 instructions when needed"
else
    test_fail "Missing install.ps1 guidance"
fi

# Check for PowerShell command examples
if grep -q "PowerShell\|cd.*install" "$VERIFY_SCRIPT"; then
    test_pass "Shows PowerShell command examples"
else
    test_fail "Missing PowerShell examples"
fi

# ============================================================================
# Test 11: Mock project validation
# ============================================================================
test_start "Functional test with mock project"

# Create a minimal ESP-IDF project structure
MOCK_PROJECT="$TEST_TEMP_DIR/mock-project"
mkdir -p "$MOCK_PROJECT/main"

# Create CMakeLists.txt
cat > "$MOCK_PROJECT/CMakeLists.txt" << 'EOF'
cmake_minimum_required(VERSION 3.16)
project(test-project)
EOF

# Create main/CMakeLists.txt
cat > "$MOCK_PROJECT/main/CMakeLists.txt" << 'EOF'
idf_component_register(SRCS "main.c")
EOF

# Create main/main.c
cat > "$MOCK_PROJECT/main/main.c" << 'EOF'
#include <stdio.h>
void app_main(void) {
    printf("Hello World\n");
}
EOF

# Create idf.sh
cat > "$MOCK_PROJECT/idf.sh" << 'EOF'
#!/usr/bin/env bash
echo "Mock idf.sh"
EOF
chmod +x "$MOCK_PROJECT/idf.sh"

test_pass "Created mock ESP-IDF project"

# Run verify-setup in mock project (should find project files)
cd "$MOCK_PROJECT"
OUTPUT=$(bash "$VERIFY_SCRIPT" 2>&1 || true)

if echo "$OUTPUT" | grep -q "CMakeLists.txt exists"; then
    test_pass "Detects CMakeLists.txt in mock project"
else
    test_fail "Does not detect CMakeLists.txt"
fi

if echo "$OUTPUT" | grep -q "main/ directory exists"; then
    test_pass "Detects main/ directory"
else
    test_fail "Does not detect main/ directory"
fi

if echo "$OUTPUT" | grep -q "idf.sh exists"; then
    test_pass "Detects idf.sh wrapper"
else
    test_fail "Does not detect idf.sh"
fi

# Test with missing components
rm -f "$MOCK_PROJECT/idf.sh"
OUTPUT=$(bash "$VERIFY_SCRIPT" 2>&1 || true)

if echo "$OUTPUT" | grep -q "idf.sh not found\|ERROR.*idf.sh"; then
    test_pass "Reports missing idf.sh as error"
else
    test_fail "Does not report missing idf.sh"
fi

cd "$SCRIPT_DIR"

# ============================================================================
# Test 12: Python environment detection
# ============================================================================
test_start "Python virtual environment detection"

# Check for venv pattern matching
if grep -q "idf.*_py.*_env" "$VERIFY_SCRIPT"; then
    test_pass "Searches for Python venv with correct pattern"
else
    test_fail "Missing Python venv pattern matching"
fi

# Check for idf_version.txt
if grep -q "idf_version.txt" "$VERIFY_SCRIPT"; then
    test_pass "Checks for idf_version.txt in venv"
else
    test_fail "Does not check idf_version.txt"
fi

# Check for venv counting
if grep -q "VENV_COUNT\|Found.*virtual environment" "$VERIFY_SCRIPT"; then
    test_pass "Counts and reports number of venvs"
else
    test_fail "Does not count virtual environments"
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
    echo "The verify-setup.sh script correctly:"
    echo "  • Validates ESP-IDF project structure"
    echo "  • Checks idf.sh wrapper configuration"
    echo "  • Detects ESP-IDF installation"
    echo "  • Verifies install.ps1 has been run"
    echo "  • Provides helpful error messages and guidance"
    echo "  • Produces well-formatted output with color codes"
    exit 0
else
    echo -e "${RED}✗ Some tests failed${NC}"
    echo ""
    echo "Please review the failures above and update verify-setup.sh."
    exit 1
fi
