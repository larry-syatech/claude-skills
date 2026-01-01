# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a Claude Code skill that enables ESP-IDF project development on Windows using Git Bash/MSYS environments. ESP-IDF 5.0+ officially removed support for MSYS/Mingw, but this skill provides a workaround using a PowerShell wrapper script.

## Architecture Overview

### Core Components

1. **skill.md** - The main skill file that Claude Code reads when invoked. Contains YAML frontmatter with skill metadata and comprehensive instructions for:
   - Using the `idf.sh` wrapper script instead of direct `idf.py` calls
   - Targeting the `build-claude` directory for builds
   - Setting up new ESP-IDF projects for Claude Code compatibility
   - Troubleshooting common Windows/MSYS issues

2. **scripts/idf-wrapper-template.sh** - Bash template that:
   - Auto-detects ESP-IDF installation via `IDF_PATH` or defaults to `~/esp/esp-idf`
   - **Validates install.ps1 prerequisites** (NEW):
     - Checks for `idf-env.json` marker file at `$IDF_TOOLS_PATH` (default: `~/.espressif`)
     - Validates Python virtual environment exists in `python_env/`
     - Verifies tools directory is populated
     - Provides clear error messages with PowerShell commands to run install.ps1
   - Converts Unix paths to Windows paths using `cygpath`
   - Removes MSYS environment variables (`MSYSTEM`, `MINGW_PREFIX`, `MSYSTEM_PREFIX`, `MSYSTEM_CHOST`, `MSYSTEM_CARCH`)
   - Launches PowerShell in a clean environment
   - Sources ESP-IDF's `export.ps1`
   - Forwards all arguments to `idf.py`

3. **scripts/verify-setup.sh** - Validates that the user's environment is correctly configured:
   - Checks ESP-IDF project structure (CMakeLists.txt, main/)
   - Validates idf.sh wrapper exists and is executable
   - Verifies ESP-IDF installation (IDF_PATH, export.ps1)
   - **Checks install.ps1 has been run** (NEW):
     - Validates `idf-env.json` exists and displays installed targets
     - Checks Python virtual environments (counts venvs, reads ESP-IDF versions)
     - Verifies tools directory has installed tools
   - Tests idf.sh functionality
   - Provides color-coded output with helpful troubleshooting guidance

4. **tests/** - Automated test suite (NEW):
   - `test-idf-wrapper.sh` - 11 test cases, 30 assertions for idf-wrapper-template.sh
   - `test-verify-setup.sh` - 12 test cases, 39 assertions for verify-setup.sh
   - `run-all-tests.sh` - Master test runner
   - Total: 69 assertions validating all skill functionality
   - All tests passing ✅

5. **Documentation Files**:
   - README.md - Human-readable skill overview
   - WINDOWS-SETUP.md - Technical implementation details
   - USAGE-GUIDE.md - Usage scenarios and examples
   - QUICK-REFERENCE.md - Command reference
   - INSTALLATION.md - Installation instructions
   - tests/README.md - Test suite documentation
   - tests/TEST-SUMMARY.md - Detailed test results

### Key Technical Patterns

#### 1. MSYS Compatibility Workaround

The skill solves the MSYS incompatibility by:
```bash
powershell.exe -NoProfile -Command "
    Remove-Item env:MSYSTEM -ErrorAction SilentlyContinue;
    Remove-Item env:MINGW_PREFIX -ErrorAction SilentlyContinue;
    Remove-Item env:MSYSTEM_PREFIX -ErrorAction SilentlyContinue;
    Remove-Item env:MSYSTEM_CHOST -ErrorAction SilentlyContinue;
    Remove-Item env:MSYSTEM_CARCH -ErrorAction SilentlyContinue;
    cd '$WIN_PROJECT_DIR';
    & '$IDF_EXPORT_SCRIPT';
    idf.py $*
"
```

This creates a clean PowerShell environment where ESP-IDF's MSYS detection check doesn't trigger.

#### 2. install.ps1 Prerequisite Detection (NEW)

Before running any ESP-IDF commands, the wrapper validates that `install.ps1` has been run:

```bash
# Determine IDF_TOOLS_PATH (default: ~/.espressif)
IDF_TOOLS_PATH="${IDF_TOOLS_PATH:-$HOME/.espressif}"

# Check for installation markers
if [ ! -f "$IDF_TOOLS_PATH/idf-env.json" ]; then
    echo "ERROR: install.ps1 has not been run"
    echo "Run in PowerShell: cd 'C:\path\to\esp-idf' && .\install.ps1"
    exit 1
fi

# Validate Python venv and tools exist
[ -d "$IDF_TOOLS_PATH/python_env" ] || exit 1
[ -d "$IDF_TOOLS_PATH/tools" ] || exit 1
```

**Key markers checked:**
- `idf-env.json` - Primary indicator that install.ps1 completed
- `python_env/idf{version}_py{major}.{minor}_env/` - Python virtual environment with ESP-IDF packages
- `tools/` - Toolchain binaries (compilers, debuggers, etc.)

This ensures users get clear error messages if they haven't run the one-time installation step.

## Common Development Commands

### Running the Test Suite (RECOMMENDED)

```bash
# Run all automated tests (69 assertions)
./tests/run-all-tests.sh

# Run individual test suites
./tests/test-idf-wrapper.sh      # Test idf-wrapper-template.sh (30 assertions)
./tests/test-verify-setup.sh     # Test verify-setup.sh (39 assertions)
```

**Expected output**: All tests should pass
```
Overall Test Suite Summary
Test suites run:    2
Suites passed:      2
Suites failed:      0
✓✓✓ ALL TEST SUITES PASSED! ✓✓✓
```

### Testing the Skill Manually

```bash
# Verify skill structure and setup
./scripts/verify-setup.sh

# Read the main skill instructions
cat skill.md

# Test the wrapper template
cp scripts/idf-wrapper-template.sh ./idf.sh
chmod +x ./idf.sh
./idf.sh --version  # Should display ESP-IDF version
```

### Modifying the Skill

When editing skill.md:
- Preserve YAML frontmatter (lines 1-5)
- Use lowercase with hyphens for the skill name
- Keep `allowed-tools` list accurate
- Test changes by using the skill in an actual ESP-IDF project

When editing scripts:
- **Always run the test suite after changes**: `./tests/run-all-tests.sh`
- Test path conversion with `cygpath -w`
- Verify MSYS environment variable removal
- Ensure auto-detection works for different ESP-IDF installation paths
- Validate install.ps1 prerequisite checks work correctly
- Update tests if adding new validation logic

### Adding New Tests

When adding new features to the wrapper scripts:

1. Add test cases to the appropriate test file:
   - `tests/test-idf-wrapper.sh` for idf-wrapper-template.sh changes
   - `tests/test-verify-setup.sh` for verify-setup.sh changes

2. Follow the test framework pattern:
```bash
test_start "Your test description"
if [ condition ]; then
    test_pass "Success message"
else
    test_fail "Failure message"
fi
```

3. Run tests to ensure they pass: `./tests/run-all-tests.sh`
4. Update `tests/TEST-SUMMARY.md` with new test coverage

## File Organization

```
build-with-esp-idf/
├── skill.md                        # Main skill (read by Claude Code)
├── CLAUDE.md                       # This file - guidance for Claude Code
├── scripts/
│   ├── idf-wrapper-template.sh     # Template for project-level wrapper
│   └── verify-setup.sh             # Setup validation
├── tests/                          # Automated test suite (NEW)
│   ├── run-all-tests.sh            # Master test runner
│   ├── test-idf-wrapper.sh         # Test idf-wrapper-template.sh
│   ├── test-verify-setup.sh        # Test verify-setup.sh
│   ├── README.md                   # Test documentation
│   └── TEST-SUMMARY.md             # Detailed test results
└── Documentation/
    ├── README.md                   # Overview
    ├── WINDOWS-SETUP.md            # Technical details
    ├── USAGE-GUIDE.md              # Usage examples
    ├── QUICK-REFERENCE.md          # Command reference
    └── INSTALLATION.md             # Installation guide
```

## Important Constraints

1. **MSYS Detection**: ESP-IDF v5.0+ explicitly blocks MSYS environments by checking for `MSYSTEM` environment variable in `idf_tools.py`

2. **install.ps1 Requirement** (NEW): ESP-IDF requires running `install.ps1` (or `install.bat`) once per installation to:
   - Download and extract toolchain binaries to `%USERPROFILE%\.espressif\tools\`
   - Create Python virtual environment with required packages in `%USERPROFILE%\.espressif\python_env\`
   - Generate `idf-env.json` configuration marker
   - The wrapper script validates these exist before attempting to run ESP-IDF commands

3. **Path Handling**: All paths must be converted from Unix-style (`/c/Users/...`) to Windows-style (`C:\Users\...`) when passing to PowerShell

4. **Build Directory**: Always use `build-claude` to avoid conflicts with manual PowerShell builds

5. **Auto-Detection Priority**:
   - **IDF_PATH**: First check `IDF_PATH` environment variable for ESP-IDF location
   - **IDF_TOOLS_PATH**: Check `IDF_TOOLS_PATH` for tools location, default to `~/.espressif`
   - **Fallbacks**: Fall back to `~/esp/esp-idf` for IDF_PATH if not set
   - **Validation**: Validate that `export.ps1` and installation markers exist before proceeding

## Skill Invocation

This skill is automatically invoked by Claude Code when:
- User asks to build/flash/configure ESP-IDF projects
- User mentions ESP32, ESP32-C6, or other ESP chips
- User asks about `idf.py` commands
- User needs to troubleshoot ESP-IDF builds on Windows

The skill description in the YAML frontmatter determines when Claude Code loads it.

## Testing Changes

### Automated Testing (Recommended)

After modifying the skill scripts:

1. **Run the automated test suite**:
   ```bash
   ./tests/run-all-tests.sh
   ```

2. **Verify all tests pass** (should see 69 passing assertions)

3. **If tests fail**:
   - Review the failure output
   - Fix the issue in the script
   - Re-run tests until all pass

### Manual Integration Testing

After automated tests pass, test in a real project:

1. Copy the entire `.claude/skills/build-with-esp-idf/` directory to a test ESP-IDF project
2. Create `idf.sh` from the template
3. Start Claude Code in the test project
4. Ask Claude to build the project
5. Verify that Claude uses the correct commands from skill.md
6. Test error scenarios (missing install.ps1, wrong paths, etc.)

### Test Coverage

The automated test suite validates:
- ✅ Auto-detection of ESP-IDF and tools paths
- ✅ install.ps1 prerequisite checks (idf-env.json, python_env, tools)
- ✅ MSYS environment variable removal (all 5 critical variables)
- ✅ PowerShell invocation with correct parameters
- ✅ Path conversion (Unix to Windows)
- ✅ Error messages are helpful and actionable
- ✅ verify-setup.sh validates project structure correctly
- ✅ Script syntax and permissions are correct

## Distribution

This skill can be:
- Committed to ESP-IDF project repositories (recommended for teams)
- Installed globally at `~/.claude/skills/` (for individual developers)
- Distributed as part of project templates

Each project using the skill needs its own `idf.sh` wrapper script with the correct ESP-IDF installation path.
