#!/usr/bin/env bash
#
# Run all tests for build-with-esp-idf skill
#
# Usage:
#   ./tests/run-all-tests.sh

set -e

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Test suite tracking
TOTAL_TEST_FILES=0
PASSED_TEST_FILES=0
FAILED_TEST_FILES=0

echo -e "${CYAN}=========================================="
echo "ESP-IDF Skill Test Suite"
echo -e "==========================================${NC}"
echo ""

# Find all test scripts
TEST_SCRIPTS=(
    "$SCRIPT_DIR/test-idf-wrapper.sh"
    "$SCRIPT_DIR/test-verify-setup.sh"
)

# Run each test script
for test_script in "${TEST_SCRIPTS[@]}"; do
    if [ ! -f "$test_script" ]; then
        echo -e "${YELLOW}⚠ WARNING:${NC} Test script not found: $test_script"
        continue
    fi

    if [ ! -x "$test_script" ]; then
        echo -e "${YELLOW}⚠ WARNING:${NC} Test script not executable: $test_script"
        echo "  Run: chmod +x $test_script"
        continue
    fi

    TOTAL_TEST_FILES=$((TOTAL_TEST_FILES + 1))

    test_name=$(basename "$test_script" .sh)
    echo -e "${CYAN}========================================"
    echo "Running: ${test_name}"
    echo -e "========================================${NC}"
    echo ""

    # Run the test script and capture exit code
    if bash "$test_script"; then
        PASSED_TEST_FILES=$((PASSED_TEST_FILES + 1))
        echo ""
        echo -e "${GREEN}✓ ${test_name} PASSED${NC}"
    else
        FAILED_TEST_FILES=$((FAILED_TEST_FILES + 1))
        echo ""
        echo -e "${RED}✗ ${test_name} FAILED${NC}"
    fi

    echo ""
done

# Overall summary
echo -e "${CYAN}=========================================="
echo "Overall Test Suite Summary"
echo -e "==========================================${NC}"
echo -e "${BLUE}Test suites run:${NC}    $TOTAL_TEST_FILES"
echo -e "${GREEN}Suites passed:${NC}     $PASSED_TEST_FILES"
echo -e "${RED}Suites failed:${NC}     $FAILED_TEST_FILES"
echo ""

if [ $FAILED_TEST_FILES -eq 0 ]; then
    echo -e "${GREEN}✓✓✓ ALL TEST SUITES PASSED! ✓✓✓${NC}"
    echo ""
    echo "The build-with-esp-idf skill is working correctly:"
    echo "  • idf-wrapper-template.sh properly configures ESP-IDF builds"
    echo "  • verify-setup.sh correctly validates project setup"
    echo "  • All prerequisite checks are functioning"
    echo "  • Error messages provide helpful guidance"
    echo ""
    echo "The skill is ready to use!"
    exit 0
else
    echo -e "${RED}✗✗✗ SOME TEST SUITES FAILED ✗✗✗${NC}"
    echo ""
    echo "Please review the failures above and fix the issues."
    echo ""
    echo "To run individual test suites:"
    for test_script in "${TEST_SCRIPTS[@]}"; do
        if [ -f "$test_script" ]; then
            echo "  $test_script"
        fi
    done
    exit 1
fi
