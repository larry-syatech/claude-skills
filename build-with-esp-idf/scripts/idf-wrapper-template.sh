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
