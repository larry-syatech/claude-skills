---
name: build-with-esp-idf
description: Configures and builds ESP-IDF projects from within Claude Code or other environments that use Git Bash/MSYS. Use when setting up ESP-IDF based ESP32/ESP32-C6 projects, running idf.py commands, building firmware, flashing devices, or troubleshooting ESP-IDF builds on Windows where MSYS/Mingw environments are not officially supported.  Not for use with PlatformIO projects.
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
---

# ESP-IDF Windows Build Configuration

This skill helps you work with ESP-IDF projects on Windows when using Claude Code (which runs in Git Bash/MSYS).

## The Problem

ESP-IDF 5.0+ removed support for MSYS/Mingw/Git Bash environments on Windows. Claude Code uses Git Bash (MINGW64) as its shell, which triggers this error:

```
ERROR: MSys/Mingw is not supported. Please follow the getting started guide
of the documentation to set up a supported environment
```

## The Solution

Use an `idf.sh` wrapper script that invokes PowerShell with a clean environment (MSYS variables removed) to run `idf.py` commands.  Note that this skill works only with ESP-IDF builds, and not PlatformIO builds.

## Key Rules for ESP-IDF Projects with Claude Code

### 1. Always Use `./idf.sh` Instead of `idf.py`

```bash
# Wrong (will fail in Git Bash)
idf.py build

# Correct
./idf.sh build
```

### 2. Use `build-claude` Directory for Separation

Claude Code builds should target the `build-claude` directory to keep builds separate from manual PowerShell builds:

```bash
# Standard build command format
./idf.sh -B build-claude build

# Other examples
./idf.sh -B build-claude flash monitor
./idf.sh -B build-claude menuconfig
./idf.sh -B build-claude clean
```

### 3. Common Build Commands Reference

```bash
# Full build
./idf.sh -B build-claude build

# Clean build
./idf.sh -B build-claude fullclean
./idf.sh -B build-claude build

# Flash and monitor
./idf.sh -B build-claude flash monitor

# Flash only (if already built)
./idf.sh -B build-claude flash

# Monitor serial output only
./idf.sh -B build-claude monitor

# Interactive configuration
./idf.sh -B build-claude menuconfig

# Size analysis
./idf.sh -B build-claude size
./idf.sh -B build-claude size-components

# Verbose output for debugging
./idf.sh -B build-claude -v build
```

## Setting Up a New ESP-IDF Project for Claude Code

When configuring a new ESP-IDF project to work with Claude Code, follow these steps:

### Step 1: Verify ESP-IDF Installation

Check that ESP-IDF is installed and that `install.ps1` has been run:

```bash
# Check that export.ps1 exists
ls "C:\Users\Larry\esp\v5.5.1\esp-idf\export.ps1"

# Check that install.ps1 has been run (creates .espressif directory with tools)
ls "$HOME/.espressif/idf-env.json"
```

**CRITICAL:** ESP-IDF requires running `install.ps1` (or `install.bat`) before first use to:
- Download and install toolchain binaries (compilers, debuggers, etc.)
- Create Python virtual environment with required packages
- Configure the environment for your target chips

If `idf-env.json` doesn't exist, run this in PowerShell:

```powershell
# Navigate to your ESP-IDF installation
cd C:\Users\Larry\esp\v5.5.1\esp-idf

# Install for all targets (recommended)
.\install.ps1

# OR install for specific targets only
.\install.ps1 esp32,esp32c6
```

This only needs to be done once per ESP-IDF installation, not per project.

### Step 2: Create the `idf.sh` Wrapper Script

Create `idf.sh` in the project root. Use the template from `scripts/idf-wrapper-template.sh`:

```bash
cp .claude/skills/build-with-esp-idf/scripts/idf-wrapper-template.sh ./idf.sh
chmod +x ./idf.sh
```

**Note:** The script automatically detects your ESP-IDF installation:
- First, it checks the `IDF_PATH` environment variable
- If not set, it defaults to `~/esp/esp-idf`
- No manual path configuration needed in most cases!

### Step 3: Verify Setup

Run the verification script:

```bash
.claude/skills/build-with-esp-idf/scripts/verify-setup.sh
```

Or manually verify:

```bash
# Test that idf.sh works
./idf.sh --version

# Try a simple command
./idf.sh -B build-claude show-env
```

### Step 4: Add to Documentation

Create or update `CLAUDE.md` in the project root to document the build process:

```markdown
## Building

This project uses ESP-IDF. On Windows with Claude Code, use the `idf.sh` wrapper:

\`\`\`bash
# Build the project
./idf.sh -B build-claude build

# Flash and monitor
./idf.sh -B build-claude flash monitor
\`\`\`

See BUILD-CLAUDE-CODE.md for details.
```

Optionally create `BUILD-CLAUDE-CODE.md` with detailed setup instructions (see `WINDOWS-SETUP.md` in this skill for a template).

## Troubleshooting

### Permission Denied on `idf.sh`

```bash
chmod +x ./idf.sh
```

### `idf.sh` Not Found

Verify the script is in the project root:

```bash
ls -la ./idf.sh
```

If missing, copy from template:

```bash
cp .claude/skills/build-with-esp-idf/scripts/idf-wrapper-template.sh ./idf.sh
chmod +x ./idf.sh
```

### PowerShell Execution Policy Error

If you see "running scripts is disabled on this system", run this in PowerShell as Administrator:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Error: "idf-env.json not found" or "Python virtual environment not found"

This means `install.ps1` has not been run. ESP-IDF requires a one-time installation step per ESP-IDF version:

```powershell
# In PowerShell, navigate to ESP-IDF installation
cd C:\Users\YourUsername\esp\v5.5.1\esp-idf

# Run install script (only needed once)
.\install.ps1

# Or for specific targets
.\install.ps1 esp32,esp32c6
```

This creates:
- `%USERPROFILE%\.espressif\idf-env.json` - Installation configuration
- `%USERPROFILE%\.espressif\python_env\` - Python virtual environment
- `%USERPROFILE%\.espressif\tools\` - Toolchain binaries (compilers, etc.)

The `idf.sh` wrapper will now detect these and verify installation before running.

### Build Fails with "The term 'idf.py' is not recognized"

This also indicates `install.ps1` hasn't been run, or the installation is incomplete. Follow the steps above.

### Build Fails with "Unknown Tool"

Check ESP-IDF version:

```bash
./idf.sh --version
```

Should be ESP-IDF v5.5.1 or compatible. Verify `IDF_EXPORT_SCRIPT` path in `idf.sh` points to your actual ESP-IDF installation.

### Cannot Find `export.ps1`

The script auto-detects ESP-IDF using `IDF_PATH` or the default `~/esp/esp-idf`. If it can't find `export.ps1`:

**Option 1: Set IDF_PATH environment variable** (recommended):

```bash
# Add to your ~/.bashrc or set in your current session:
export IDF_PATH=/c/Users/YourUsername/esp/esp-idf

# Or for version-specific installations:
export IDF_PATH=/c/Users/YourUsername/esp/v5.5.1/esp-idf
```

**Option 2: Use the default path:**

Ensure ESP-IDF is installed at `C:\Users\<YourUsername>\esp\esp-idf`

Common ESP-IDF installation paths:
- `C:\Users\<Username>\esp\esp-idf` (default)
- `C:\Users\<Username>\esp\v5.5.1\esp-idf` (version-specific)
- `C:\Espressif\frameworks\esp-idf-v5.5.1` (installer default)

### Build Artifacts Location

All build outputs go to `build-claude/`:

- Firmware binary: `build-claude/<project-name>.bin`
- Build logs: `build-claude/build.log`
- Configuration: `build-claude/config/`
- Flash args: `build-claude/flash_args`

## Additional Resources

- See [WINDOWS-SETUP.md](WINDOWS-SETUP.md) for detailed Windows setup explanation
- ESP-IDF Documentation: https://docs.espressif.com/projects/esp-idf/
- ESP-IDF Windows Setup: https://docs.espressif.com/projects/esp-idf/en/stable/esp32/get-started/windows-setup.html
