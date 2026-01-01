# Windows ESP-IDF Setup Details

## Background: Why the `idf.sh` Wrapper is Needed

ESP-IDF 5.0+ removed support for MSYS/Mingw/Git Bash environments on Windows. This was announced in ESP-IDF v4.0 as deprecated and fully removed in v5.0.

### The Problem

Claude Code on Windows runs in MSYS/Mingw (Git Bash), but ESP-IDF 5.5.1 explicitly blocks this environment. The detection happens in `idf_tools.py` which checks for the `MSYSTEM` environment variable:

```python
# From ESP-IDF idf_tools.py
if os.name == 'nt' and 'MSYSTEM' in os.environ:
    fatal('MSys/Mingw is not supported. Please follow the getting started guide...')
```

Even if you run `export.ps1` before starting Claude Code, the MSYS environment variables (`MSYSTEM`, `MINGW_PREFIX`, etc.) are inherited by any PowerShell instances launched from Git Bash.

### The Solution

The `idf.sh` wrapper script:
1. Removes MSYS-related environment variables
2. Launches PowerShell (which ESP-IDF 5.5.1 officially supports)
3. Sources the ESP-IDF environment (`export.ps1`)
4. Runs your `idf.py` command with all arguments passed through

## Technical Implementation

### How `idf.sh` Works

```bash
#!/usr/bin/env bash
# Get project directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WIN_PROJECT_DIR=$(cygpath -w "$SCRIPT_DIR")

# Path to ESP-IDF
IDF_EXPORT_SCRIPT="C:\Users\Larry\esp\v5.5.1\esp-idf\export.ps1"

# Build command
IDF_COMMAND="idf.py $*"

# Execute in clean PowerShell environment
powershell.exe -NoProfile -Command "
    Remove-Item env:MSYSTEM -ErrorAction SilentlyContinue;
    Remove-Item env:MINGW_PREFIX -ErrorAction SilentlyContinue;
    Remove-Item env:MSYSTEM_PREFIX -ErrorAction SilentlyContinue;
    cd '$WIN_PROJECT_DIR';
    & '$IDF_EXPORT_SCRIPT';
    $IDF_COMMAND
"
```

### Key Components

1. **Path conversion**: Uses `cygpath -w` to convert Unix-style paths to Windows paths
2. **Environment cleanup**: Removes MSYS variables that trigger ESP-IDF's detection
3. **PowerShell invocation**: Uses `-NoProfile` for faster startup
4. **ESP-IDF initialization**: Sources `export.ps1` to set up IDF environment
5. **Command passthrough**: Forwards all arguments (`$*`) to `idf.py`

## Checking Prerequisites

Before building ESP-IDF projects, verify your setup:

### 1. ESP-IDF Installation

```bash
# Check if export.ps1 exists (adjust path to your installation)
ls "C:\Users\Larry\esp\v5.5.1\esp-idf\export.ps1"
```

Common ESP-IDF installation locations:
- `C:\Users\<Username>\esp\v5.5.1\esp-idf\`
- `C:\Espressif\frameworks\esp-idf-v5.5.1\`

### 2. PowerShell Execution Policy

PowerShell may block script execution. Check with:

```powershell
# Run this in PowerShell
Get-ExecutionPolicy
```

If it returns `Restricted`, update it:

```powershell
# Run as Administrator
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 3. Project Structure

Verify the project has required files:

```bash
# Check for CMakeLists.txt
ls -la CMakeLists.txt

# Check for idf.sh wrapper
ls -la idf.sh

# Verify idf.sh is executable
chmod +x idf.sh
```

### 4. ESP-IDF Version

Verify ESP-IDF version is compatible (5.5.1 recommended):

```bash
./idf.sh --version
```

Expected output:
```
ESP-IDF v5.5.1
```

## Build Directory Strategy

### Why Use `build-claude`?

Claude Code builds should use a separate directory (`build-claude`) instead of the default `build` for several reasons:

1. **Avoid conflicts**: Manual PowerShell builds and Claude builds won't interfere
2. **Clear attribution**: Easy to identify which environment created the build
3. **Parallel workflows**: You can build with both environments simultaneously
4. **Cleaner git history**: `.gitignore` can exclude both directories

### Directory Structure

```
your-project/
├── build/              # Manual PowerShell builds (git-ignored)
├── build-claude/       # Claude Code builds (git-ignored)
├── idf.sh              # Wrapper script
├── CMakeLists.txt      # Project configuration
└── main/
    └── main.c          # Your application
```

### Using the Build Directory

Always specify `-B build-claude`:

```bash
# Correct
./idf.sh -B build-claude build

# Default (uses build/ directory)
./idf.sh build  # Avoid mixing with manual builds
```

## Common Build Tasks

### Configuration

```bash
# Open interactive configuration menu
./idf.sh -B build-claude menuconfig

# Show current configuration
./idf.sh -B build-claude show-env

# Show configuration variables
./idf.sh -B build-claude show-efuse-summary
```

### Building

```bash
# Incremental build
./idf.sh -B build-claude build

# Clean build (remove artifacts but keep config)
./idf.sh -B build-claude clean
./idf.sh -B build-claude build

# Full clean (remove everything including CMake cache)
./idf.sh -B build-claude fullclean
./idf.sh -B build-claude build

# Verbose build output
./idf.sh -B build-claude -v build
```

### Flashing and Monitoring

```bash
# Flash only (requires prior build)
./idf.sh -B build-claude flash

# Build and flash
./idf.sh -B build-claude build flash

# Flash and open serial monitor
./idf.sh -B build-claude flash monitor

# Monitor only (without flashing)
./idf.sh -B build-claude monitor

# Specify serial port
./idf.sh -B build-claude -p COM4 flash monitor
```

### Analysis

```bash
# Show binary size
./idf.sh -B build-claude size

# Show size by component
./idf.sh -B build-claude size-components

# Show size by file
./idf.sh -B build-claude size-files
```

## Build Artifacts Location

All build outputs are in `build-claude/`:

### Key Files

```
build-claude/
├── <project-name>.bin      # Main firmware binary
├── <project-name>.elf      # ELF file with debug symbols
├── bootloader/
│   └── bootloader.bin      # Bootloader binary
├── partition_table/
│   └── partition-table.bin # Partition table
├── flash_args              # Arguments for flashing
├── build.log               # Build log
└── config/
    └── sdkconfig.h         # Generated configuration header
```

### Flash Command

The build process generates `flash_args` which contains:

```
--flash_mode dio --flash_freq 80m --flash_size 8MB
0x0 bootloader/bootloader.bin
0x8000 partition_table/partition-table.bin
0x10000 <project-name>.bin
```

## Troubleshooting Common Issues

### Error: "MSys/Mingw is not supported"

**Cause**: Running `idf.py` directly instead of through `idf.sh`

**Solution**: Always use `./idf.sh` wrapper:
```bash
# Wrong
idf.py build

# Correct
./idf.sh build
```

### Error: "Cannot run a document without a '.ps1' extension"

**Cause**: PowerShell execution policy blocks scripts

**Solution**: Update execution policy:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Error: "The term 'idf.py' is not recognized"

**Cause**: ESP-IDF environment not initialized or `IDF_EXPORT_SCRIPT` path is wrong

**Solution**: Edit `idf.sh` and verify the path to `export.ps1`:
```bash
# Edit this line in idf.sh
IDF_EXPORT_SCRIPT="C:\Users\YourUsername\esp\v5.5.1\esp-idf\export.ps1"
```

### Error: "Permission denied: ./idf.sh"

**Cause**: Script not marked as executable

**Solution**:
```bash
chmod +x ./idf.sh
```

### Build Fails with Compilation Errors

**Debug steps**:

1. Check verbose output:
   ```bash
   ./idf.sh -B build-claude -v build
   ```

2. Try a clean build:
   ```bash
   ./idf.sh -B build-claude fullclean
   ./idf.sh -B build-claude build
   ```

3. Verify ESP-IDF version:
   ```bash
   ./idf.sh --version
   ```

4. Check project configuration:
   ```bash
   ./idf.sh -B build-claude menuconfig
   ```

### Serial Port Issues

**Finding the port**:

Windows:
```powershell
# In PowerShell
Get-WmiObject Win32_SerialPort | Select-Object Name, DeviceID
```

Git Bash:
```bash
ls /dev/ttyS* /dev/ttyUSB* 2>/dev/null
```

**Specify port explicitly**:
```bash
./idf.sh -B build-claude -p COM4 flash monitor
```

## Alternative: Direct PowerShell Invocation

If you prefer not to use the wrapper script, you can run commands directly from Git Bash:

```bash
powershell.exe -NoProfile -Command "
    Remove-Item env:MSYSTEM -ErrorAction SilentlyContinue;
    Remove-Item env:MINGW_PREFIX -ErrorAction SilentlyContinue;
    Remove-Item env:MSYSTEM_PREFIX -ErrorAction SilentlyContinue;
    cd 'C:\Your\Project\Path';
    & 'C:\Users\Larry\esp\v5.5.1\esp-idf\export.ps1';
    idf.py -B build-claude build
"
```

However, the `idf.sh` wrapper is recommended for convenience and consistency.

## ESP-IDF Officially Supported Environments

According to ESP-IDF documentation, these Windows environments are supported:

1. **Windows Command Prompt** (`cmd.exe`)
2. **PowerShell** (preferred)
3. **ESP-IDF Eclipse IDE**

Git Bash (MSYS2/Mingw) support was:
- Deprecated in ESP-IDF v4.0
- Completely removed in ESP-IDF v5.0

This is why the wrapper approach is necessary.

## References

- [ESP-IDF Windows Setup Documentation](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/get-started/windows-setup.html)
- [ESP-IDF Build System](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/api-guides/build-system.html)
- [ESP-IDF VSCode Extension Issue #856](https://github.com/espressif/vscode-esp-idf-extension/issues/856)
- [ESP-IDF Release v5.5.1](https://github.com/espressif/esp-idf/releases/tag/v5.5.1)
