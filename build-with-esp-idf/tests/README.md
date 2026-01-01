# Test Suite for build-with-esp-idf Skill

This directory contains automated tests to verify the correctness of the ESP-IDF build skill components.

## Test Files

### test-idf-wrapper.sh
Tests the `idf-wrapper-template.sh` script to ensure it:
- Auto-detects ESP-IDF installation paths correctly
- Validates that `install.ps1` has been run
- Checks for required prerequisites (idf-env.json, python_env, tools)
- Removes MSYS environment variables properly
- Provides helpful error messages
- Correctly invokes PowerShell with proper path conversion

**Run with:**
```bash
./tests/test-idf-wrapper.sh
```

### test-verify-setup.sh
Tests the `verify-setup.sh` validation script to ensure it:
- Checks ESP-IDF project structure (CMakeLists.txt, main/)
- Validates idf.sh wrapper configuration
- Detects ESP-IDF installation and verify install.ps1 execution
- Checks for Python virtual environments
- Validates build directory configuration
- Provides well-formatted output with helpful guidance

**Run with:**
```bash
./tests/test-verify-setup.sh
```

## Running All Tests

Run all tests at once:

```bash
./tests/run-all-tests.sh
```

Or run individually:

```bash
./tests/test-idf-wrapper.sh
./tests/test-verify-setup.sh
```

## Test Coverage

The test suite validates:

### 1. ESP-IDF Path Detection
- ✓ Checks `IDF_PATH` environment variable first
- ✓ Falls back to default `~/esp/esp-idf` path
- ✓ Validates `export.ps1` exists at detected path
- ✓ Provides clear error messages if paths are wrong

### 2. Installation Prerequisites (install.ps1)
- ✓ Checks for `idf-env.json` marker file
- ✓ Validates Python virtual environment exists
- ✓ Checks tools directory is populated
- ✓ Respects `IDF_TOOLS_PATH` environment variable
- ✓ Uses correct default path (`~/.espressif`)

### 3. MSYS Compatibility
- ✓ Removes all critical MSYS environment variables:
  - MSYSTEM
  - MINGW_PREFIX
  - MSYSTEM_PREFIX
  - MSYSTEM_CHOST
  - MSYSTEM_CARCH
- ✓ Invokes PowerShell with clean environment

### 4. Error Messages
- ✓ Provides actionable guidance for missing prerequisites
- ✓ Shows PowerShell commands to run install.ps1
- ✓ Lists common installation paths
- ✓ Explains what each error means

### 5. Script Quality
- ✓ Valid bash syntax (no syntax errors)
- ✓ Proper shebang (`#!/usr/bin/env bash`)
- ✓ Executable permissions
- ✓ Includes documentation and usage examples

## Adding New Tests

To add a new test:

1. Create a new test script: `tests/test-your-feature.sh`
2. Use the test framework pattern:
   ```bash
   #!/usr/bin/env bash
   set -e

   # Test counters
   TESTS_RUN=0
   TESTS_PASSED=0
   TESTS_FAILED=0

   test_start() { ... }
   test_pass() { ... }
   test_fail() { ... }

   # Your tests here
   test_start "Test description"
   if [ condition ]; then
       test_pass "Success message"
   else
       test_fail "Failure message"
   fi
   ```

3. Make it executable: `chmod +x tests/test-your-feature.sh`
4. Add it to `run-all-tests.sh`

## Continuous Integration

These tests can be integrated into CI/CD pipelines:

```yaml
# Example GitHub Actions workflow
- name: Run skill tests
  run: |
    cd .claude/skills/build-with-esp-idf
    ./tests/run-all-tests.sh
```

## Test Philosophy

These tests follow the principle of:
- **Black box testing**: Test the external behavior, not implementation details
- **Fail-fast**: Stop on first error to catch issues early
- **Clear output**: Use colors and symbols to make results easy to scan
- **Helpful failures**: Explain what went wrong and how to fix it

## Mock Testing

Tests create temporary mock environments to validate behavior without requiring a full ESP-IDF installation:

- Mock ESP-IDF directory with `export.ps1`
- Mock `.espressif` directory with tools and Python venv
- Mock ESP-IDF project structure (CMakeLists.txt, main/)

This allows tests to run quickly and reliably in any environment.

## Expected Results

All tests should pass with output like:

```
Test 1: Template file exists and is valid bash
----------------------------------------
✓ PASS: Template file exists
✓ PASS: Has correct shebang (#!/usr/bin/env bash)
✓ PASS: Bash syntax is valid

...

==========================================
Test Results Summary
==========================================
Tests run:     50
Tests passed:  50
Tests failed:  0

✓ All tests passed!
```

## Troubleshooting Test Failures

### "Template file not found"
The test is looking for `scripts/idf-wrapper-template.sh`. Ensure the file exists and you're running tests from the skill root directory.

### "Bash syntax error detected"
Run `bash -n scripts/idf-wrapper-template.sh` to see the syntax error.

### "Mock environment test failed"
Check that temporary directory permissions allow file creation (`/tmp/idf-wrapper-test-*`).

### Tests hang or timeout
Ensure no background PowerShell processes are left running. The tests clean up automatically on exit.

## Development Workflow

When modifying the skill scripts:

1. Make your changes to `scripts/idf-wrapper-template.sh` or `scripts/verify-setup.sh`
2. Run the relevant test: `./tests/test-idf-wrapper.sh`
3. Fix any failures
4. Run all tests: `./tests/run-all-tests.sh`
5. Commit when all tests pass

## Test Maintenance

Update tests when:
- Adding new validation checks to scripts
- Changing error messages
- Adding new environment variables
- Modifying path detection logic
- Adding new prerequisite checks

Keep tests in sync with the actual script behavior to maintain reliability.
