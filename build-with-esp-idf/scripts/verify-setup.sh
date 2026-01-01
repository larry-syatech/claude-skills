#!/usr/bin/env bash
#
# ESP-IDF Setup Verification Script
#
# Verifies that an ESP-IDF project is correctly configured for building
# with Claude Code on Windows (Git Bash/MSYS environment).
#
# Usage:
#   .claude/skills/build-with-esp-idf/scripts/verify-setup.sh

set -e

echo "=========================================="
echo "ESP-IDF Setup Verification for Claude Code"
echo "=========================================="
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

SUCCESS=0
WARNINGS=0
ERRORS=0

# Helper functions
print_ok() {
    echo -e "${GREEN}✓ OK:${NC} $1"
    SUCCESS=$((SUCCESS + 1))
}

print_warning() {
    echo -e "${YELLOW}⚠ WARNING:${NC} $1"
    WARNINGS=$((WARNINGS + 1))
}

print_error() {
    echo -e "${RED}✗ ERROR:${NC} $1"
    ERRORS=$((ERRORS + 1))
}

echo "1. Checking project structure..."
echo "----------------------------------------"

# Check for CMakeLists.txt
if [ -f "./CMakeLists.txt" ]; then
    print_ok "CMakeLists.txt exists in project root"
else
    print_error "CMakeLists.txt not found in project root"
    echo "         ESP-IDF projects require CMakeLists.txt"
fi

# Check for main directory
if [ -d "./main" ]; then
    print_ok "main/ directory exists"

    # Check for main component files
    if [ -f "./main/CMakeLists.txt" ]; then
        print_ok "main/CMakeLists.txt exists"
    else
        print_warning "main/CMakeLists.txt not found (may cause build issues)"
    fi

    # Check for main source file
    if [ -f "./main/main.c" ] || [ -f "./main/main.cpp" ]; then
        print_ok "Main source file found (main.c or main.cpp)"
    else
        print_warning "No main.c or main.cpp found in main/ directory"
    fi
else
    print_error "main/ directory not found"
    echo "         ESP-IDF projects require a main/ component directory"
fi

echo ""
echo "2. Checking idf.sh wrapper script..."
echo "----------------------------------------"

# Check for idf.sh
if [ -f "./idf.sh" ]; then
    print_ok "idf.sh exists in project root"

    # Check if executable
    if [ -x "./idf.sh" ]; then
        print_ok "idf.sh is executable"
    else
        print_warning "idf.sh is not executable (run: chmod +x ./idf.sh)"
    fi

    # Check if idf.sh uses auto-detection
    if grep -q "Auto-detect ESP-IDF installation path" "./idf.sh"; then
        print_ok "idf.sh uses auto-detection for ESP-IDF path"

        # Check IDF_PATH environment variable
        if [ -n "$IDF_PATH" ]; then
            print_ok "IDF_PATH environment variable is set: $IDF_PATH"

            # Verify export.ps1 exists at IDF_PATH
            if [ -f "$IDF_PATH/export.ps1" ]; then
                print_ok "export.ps1 found at \$IDF_PATH/export.ps1"
            else
                print_error "export.ps1 not found at \$IDF_PATH/export.ps1"
                echo "         IDF_PATH may be incorrect: $IDF_PATH"
            fi
        else
            print_warning "IDF_PATH not set, will use default ~/esp/esp-idf"

            # Check default path
            WIN_USERNAME="${USERNAME:-${USER}}"
            DEFAULT_PATH="/c/Users/${WIN_USERNAME}/esp/esp-idf"
            if [ -f "$DEFAULT_PATH/export.ps1" ]; then
                print_ok "export.ps1 found at default path: $DEFAULT_PATH"
            else
                print_warning "export.ps1 not found at default path: $DEFAULT_PATH"
                echo "         Consider setting IDF_PATH environment variable"
            fi
        fi
    else
        # Legacy hardcoded path check
        if grep -q "IDF_EXPORT_SCRIPT=" "./idf.sh"; then
            IDF_PATH_IN_SCRIPT=$(grep "IDF_EXPORT_SCRIPT=" "./idf.sh" | grep -v "^#" | cut -d'"' -f2)
            print_warning "idf.sh uses hardcoded path (consider updating to auto-detect version)"
            echo "         Configured: $IDF_PATH_IN_SCRIPT"

            # Try to verify the path exists (convert to Unix path for checking)
            UNIX_IDF_PATH=$(echo "$IDF_PATH_IN_SCRIPT" | sed 's/\\/\//g' | sed 's/C:/\/c/')
            if [ -f "$UNIX_IDF_PATH" ]; then
                print_ok "export.ps1 file exists at configured path"
            else
                print_error "export.ps1 not found at: $IDF_PATH_IN_SCRIPT"
                echo "         Update idf.sh from template or set IDF_PATH"
            fi
        else
            print_error "Cannot determine ESP-IDF path configuration in idf.sh"
        fi
    fi
else
    print_error "idf.sh not found in project root"
    echo "         Copy from: .claude/skills/build-with-esp-idf/scripts/idf-wrapper-template.sh"
    echo "         Run: cp .claude/skills/build-with-esp-idf/scripts/idf-wrapper-template.sh ./idf.sh"
    echo "              chmod +x ./idf.sh"
fi

echo ""
echo "3. Checking build directory configuration..."
echo "----------------------------------------"

# Check for build-claude directory
if [ -d "./build-claude" ]; then
    print_ok "build-claude/ directory exists"

    # Check for CMakeCache
    if [ -f "./build-claude/CMakeCache.txt" ]; then
        print_ok "CMake cache exists (project has been configured)"
    else
        print_warning "No CMake cache found (run: ./idf.sh -B build-claude build)"
    fi
else
    print_warning "build-claude/ directory not found (will be created on first build)"
fi

# Check .gitignore
if [ -f "./.gitignore" ]; then
    if grep -q "build-claude" "./.gitignore"; then
        print_ok "build-claude/ is git-ignored"
    else
        print_warning "build-claude/ not in .gitignore (consider adding it)"
    fi
else
    print_warning ".gitignore not found (consider creating one)"
fi

echo ""
echo "4. Checking documentation..."
echo "----------------------------------------"

# Check for CLAUDE.md
if [ -f "./CLAUDE.md" ]; then
    print_ok "CLAUDE.md exists (project documentation for Claude Code)"
else
    print_warning "CLAUDE.md not found (recommended for documenting build process)"
fi

# Check for BUILD-CLAUDE-CODE.md
if [ -f "./BUILD-CLAUDE-CODE.md" ]; then
    print_ok "BUILD-CLAUDE-CODE.md exists (Windows build instructions)"
else
    print_warning "BUILD-CLAUDE-CODE.md not found (recommended for Windows setup docs)"
fi

echo ""
echo "5. Checking ESP-IDF installation (install.ps1)..."
echo "----------------------------------------"

# Determine IDF_TOOLS_PATH (where install.ps1 installs tools)
if [ -n "$IDF_TOOLS_PATH" ]; then
    UNIX_IDF_TOOLS_PATH="$IDF_TOOLS_PATH"
else
    WIN_USERNAME="${USERNAME:-${USER}}"
    UNIX_IDF_TOOLS_PATH="/c/Users/${WIN_USERNAME}/.espressif"
fi

WIN_IDF_TOOLS_PATH=$(cygpath -w "$UNIX_IDF_TOOLS_PATH" 2>/dev/null || echo "$UNIX_IDF_TOOLS_PATH")

echo "Checking IDF_TOOLS_PATH: $UNIX_IDF_TOOLS_PATH"

# Check for idf-env.json (primary marker that install.ps1 has been run)
IDF_ENV_JSON="$UNIX_IDF_TOOLS_PATH/idf-env.json"
if [ -f "$IDF_ENV_JSON" ]; then
    print_ok "idf-env.json found (install.ps1 has been run)"

    # Show installed targets/features
    if command -v python3 &> /dev/null || command -v python &> /dev/null; then
        PYTHON_CMD=$(command -v python3 || command -v python)
        TARGETS=$($PYTHON_CMD -c "import json; data=json.load(open('$IDF_ENV_JSON')); print(','.join(data.get('targets', [])))" 2>/dev/null || echo "unknown")
        if [ "$TARGETS" != "unknown" ] && [ -n "$TARGETS" ]; then
            print_ok "Installed targets: $TARGETS"
        fi
    fi
else
    print_error "idf-env.json not found - install.ps1 has not been run"
    echo "         Expected: $IDF_ENV_JSON"
    echo ""
    echo "         To fix, run in PowerShell:"

    # Determine ESP-IDF path for the error message
    if [ -n "$IDF_PATH" ]; then
        WIN_IDF_PATH=$(cygpath -w "$IDF_PATH" 2>/dev/null || echo "$IDF_PATH")
    else
        WIN_USERNAME="${USERNAME:-${USER}}"
        WIN_IDF_PATH="C:\\Users\\${WIN_USERNAME}\\esp\\esp-idf"
    fi

    echo "           cd '$WIN_IDF_PATH'"
    echo "           .\\install.ps1"
    echo ""
    echo "         Or for specific targets:"
    echo "           .\\install.ps1 esp32,esp32c6"
fi

# Check for Python virtual environment
PYTHON_ENV_DIR="$UNIX_IDF_TOOLS_PATH/python_env"
if [ -d "$PYTHON_ENV_DIR" ]; then
    print_ok "Python virtual environment directory exists"

    # Check for at least one venv (idf*_py*_env pattern)
    VENV_COUNT=$(find "$PYTHON_ENV_DIR" -maxdepth 1 -type d -name "idf*_py*_env" 2>/dev/null | wc -l)
    if [ "$VENV_COUNT" -gt 0 ]; then
        print_ok "Found $VENV_COUNT Python virtual environment(s)"

        # List the venvs
        for venv in "$PYTHON_ENV_DIR"/idf*_py*_env; do
            if [ -d "$venv" ]; then
                VENV_NAME=$(basename "$venv")

                # Check for idf_version.txt marker
                if [ -f "$venv/idf_version.txt" ]; then
                    IDF_VER=$(cat "$venv/idf_version.txt" 2>/dev/null || echo "unknown")
                    print_ok "  - $VENV_NAME (ESP-IDF v$IDF_VER)"
                else
                    print_ok "  - $VENV_NAME"
                fi
            fi
        done
    else
        print_warning "Python environment directory exists but no venvs found"
        echo "         install.ps1 may not have completed successfully"
    fi
else
    print_error "Python virtual environment directory not found"
    echo "         Expected: $PYTHON_ENV_DIR"
    echo "         This indicates install.ps1 has not been run or failed"
fi

# Check for tools directory
TOOLS_DIR="$UNIX_IDF_TOOLS_PATH/tools"
if [ -d "$TOOLS_DIR" ]; then
    # Count installed tools
    TOOL_COUNT=$(find "$TOOLS_DIR" -maxdepth 1 -type d ! -name "tools" 2>/dev/null | wc -l)
    if [ "$TOOL_COUNT" -gt 0 ]; then
        print_ok "ESP-IDF tools directory exists with $TOOL_COUNT tool(s) installed"
    else
        print_warning "Tools directory exists but appears empty"
    fi
else
    print_error "ESP-IDF tools directory not found"
    echo "         Expected: $TOOLS_DIR"
    echo "         This indicates install.ps1 has not been run or failed"
fi

echo ""
echo "6. Testing idf.sh functionality..."
echo "----------------------------------------"

if [ -f "./idf.sh" ] && [ -x "./idf.sh" ]; then
    # Test idf.sh --version
    echo "Running: ./idf.sh --version"
    if ./idf.sh --version > /tmp/idf-version.txt 2>&1; then
        VERSION=$(cat /tmp/idf-version.txt | grep -i "ESP-IDF" | head -n 1)
        if [ -n "$VERSION" ]; then
            print_ok "idf.sh is working: $VERSION"
        else
            print_warning "idf.sh executed but couldn't determine ESP-IDF version"
            echo "         Output: $(cat /tmp/idf-version.txt)"
        fi
    else
        print_error "idf.sh --version failed"
        echo "         Check ESP-IDF installation and IDF_EXPORT_SCRIPT path"
        if [ -f /tmp/idf-version.txt ]; then
            echo "         Error: $(cat /tmp/idf-version.txt | head -n 3)"
        fi
    fi
    rm -f /tmp/idf-version.txt
else
    print_warning "Skipping idf.sh test (script not found or not executable)"
fi

echo ""
echo "=========================================="
echo "Verification Summary"
echo "=========================================="
echo -e "${GREEN}Passed:${NC}   $SUCCESS checks"
echo -e "${YELLOW}Warnings:${NC} $WARNINGS warnings"
echo -e "${RED}Errors:${NC}   $ERRORS errors"
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ Setup looks good! Ready to build with Claude Code.${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Build: ./idf.sh -B build-claude build"
    echo "  2. Flash: ./idf.sh -B build-claude flash monitor"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ Setup has warnings but should work.${NC}"
    echo "Consider addressing warnings for optimal experience."
    echo ""
    echo "Try building: ./idf.sh -B build-claude build"
    exit 0
else
    echo -e "${RED}✗ Setup has errors that need to be fixed.${NC}"
    echo ""
    echo "Quick fix guide:"
    echo "  1. Missing idf.sh:"
    echo "     cp .claude/skills/build-with-esp-idf/scripts/idf-wrapper-template.sh ./idf.sh"
    echo "     chmod +x ./idf.sh"
    echo ""
    echo "  2. Wrong IDF_EXPORT_SCRIPT path:"
    echo "     Edit idf.sh and update the path to your ESP-IDF installation"
    echo ""
    echo "  3. Missing CMakeLists.txt:"
    echo "     Your project may not be an ESP-IDF project, or files are missing"
    exit 1
fi
