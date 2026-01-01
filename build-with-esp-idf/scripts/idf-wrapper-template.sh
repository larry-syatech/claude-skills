#!/usr/bin/env bash
#
# ESP-IDF wrapper for Claude Code (Git Bash on Windows)
#
# ESP-IDF 5.5+ doesn't support MSYS/Mingw environments, but Claude Code uses Git Bash.
# This script invokes PowerShell with a clean environment to run idf.py commands.
#
# Usage:
#   ./idf.sh build
#   ./idf.sh flash
#   ./idf.sh menuconfig
#   ./idf.sh fullclean
#   ./idf.sh <any idf.py command>

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Convert Unix path to Windows path for PowerShell
WIN_PROJECT_DIR=$(cygpath -w "$SCRIPT_DIR")

# Auto-detect ESP-IDF installation path
# Priority: 1. IDF_PATH environment variable, 2. Default ~/esp/esp-idf
if [ -n "$IDF_PATH" ]; then
    # IDF_PATH is set, use it
    UNIX_IDF_PATH="$IDF_PATH"
else
    # Fall back to default installation location
    # Auto-detect Windows username
    WIN_USERNAME="${USERNAME:-${USER}}"
    UNIX_IDF_PATH="/c/Users/${WIN_USERNAME}/esp/esp-idf"
fi

# Convert to Windows path and construct export.ps1 location
WIN_IDF_PATH=$(cygpath -w "$UNIX_IDF_PATH")
IDF_EXPORT_SCRIPT="${WIN_IDF_PATH}\\export.ps1"

# Verify export.ps1 exists
if [ ! -f "$UNIX_IDF_PATH/export.ps1" ]; then
    echo "ERROR: ESP-IDF export.ps1 not found at: $IDF_EXPORT_SCRIPT"
    echo ""
    echo "Checked path: $UNIX_IDF_PATH/export.ps1"
    echo ""
    echo "Please ensure ESP-IDF is installed, or set IDF_PATH environment variable:"
    echo "  export IDF_PATH=/c/path/to/esp-idf"
    echo ""
    echo "Common installation paths:"
    echo "  - /c/Users/<Username>/esp/esp-idf"
    echo "  - /c/Espressif/frameworks/esp-idf-v5.x.x"
    exit 1
fi

# Determine IDF_TOOLS_PATH (where install.ps1 puts tools and python venv)
# Priority: 1. IDF_TOOLS_PATH environment variable, 2. Default ~/.espressif
if [ -n "$IDF_TOOLS_PATH" ]; then
    UNIX_IDF_TOOLS_PATH="$IDF_TOOLS_PATH"
else
    # Convert Windows path to Unix path if needed
    WIN_USERNAME="${USERNAME:-${USER}}"
    UNIX_IDF_TOOLS_PATH="/c/Users/${WIN_USERNAME}/.espressif"
fi

# Verify install.ps1 has been run by checking for key markers
IDF_ENV_JSON="$UNIX_IDF_TOOLS_PATH/idf-env.json"
PYTHON_ENV_DIR="$UNIX_IDF_TOOLS_PATH/python_env"
TOOLS_DIR="$UNIX_IDF_TOOLS_PATH/tools"

if [ ! -f "$IDF_ENV_JSON" ]; then
    echo "ERROR: ESP-IDF installation incomplete - idf-env.json not found"
    echo ""
    echo "Expected location: $IDF_ENV_JSON"
    echo ""
    echo "This indicates that install.ps1 (or install.bat) has not been run."
    echo ""
    echo "To fix this, run the following in PowerShell:"
    echo "  cd '$WIN_IDF_PATH'"
    echo "  .\\install.ps1"
    echo ""
    echo "Or install for specific targets:"
    echo "  .\\install.ps1 esp32,esp32c6"
    echo ""
    exit 1
fi

if [ ! -d "$PYTHON_ENV_DIR" ]; then
    echo "ERROR: Python virtual environment not found"
    echo ""
    echo "Expected location: $PYTHON_ENV_DIR"
    echo ""
    echo "This indicates install.ps1 did not complete successfully."
    echo "Please run install.ps1 in PowerShell:"
    echo "  cd '$WIN_IDF_PATH'"
    echo "  .\\install.ps1"
    echo ""
    exit 1
fi

if [ ! -d "$TOOLS_DIR" ]; then
    echo "ERROR: ESP-IDF tools directory not found"
    echo ""
    echo "Expected location: $TOOLS_DIR"
    echo ""
    echo "This indicates install.ps1 did not complete successfully."
    echo "Please run install.ps1 in PowerShell:"
    echo "  cd '$WIN_IDF_PATH'"
    echo "  .\\install.ps1"
    echo ""
    exit 1
fi

# Build the idf.py command from all arguments
IDF_COMMAND="idf.py $*"

# Run idf.py in PowerShell with MSYS environment variables removed
powershell.exe -NoProfile -Command "
    Remove-Item env:MSYSTEM -ErrorAction SilentlyContinue;
    Remove-Item env:MINGW_PREFIX -ErrorAction SilentlyContinue;
    Remove-Item env:MSYSTEM_PREFIX -ErrorAction SilentlyContinue;
    Remove-Item env:MSYSTEM_CHOST -ErrorAction SilentlyContinue;
    Remove-Item env:MSYSTEM_CARCH -ErrorAction SilentlyContinue;
    cd '$WIN_PROJECT_DIR';
    & '$IDF_EXPORT_SCRIPT';
    $IDF_COMMAND
"
