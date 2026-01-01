# Quick Reference: ESP-IDF on Windows with Claude Code

## Essential Commands

```bash
# Build
./idf.sh -B build-claude build

# Clean build
./idf.sh -B build-claude fullclean
./idf.sh -B build-claude build

# Flash and monitor
./idf.sh -B build-claude flash monitor

# Configure
./idf.sh -B build-claude menuconfig

# Size analysis
./idf.sh -B build-claude size-components

# Verify setup
.claude/skills/build-with-esp-idf/scripts/verify-setup.sh
```

## First-Time Setup

```bash
# 1. Copy wrapper script
cp .claude/skills/build-with-esp-idf/scripts/idf-wrapper-template.sh ./idf.sh
chmod +x ./idf.sh

# 2. Edit idf.sh and update this line:
#    IDF_EXPORT_SCRIPT="C:\Users\YourUsername\esp\v5.5.1\esp-idf\export.ps1"

# 3. Test
./idf.sh --version

# 4. Build
./idf.sh -B build-claude build
```

## Ask Claude

Instead of running commands manually, just ask Claude:

| What you want | Just ask Claude |
|---------------|-----------------|
| Build project | "Build this project" |
| Flash device | "Flash the firmware" |
| Clean build | "Do a clean build" |
| Configure | "Open menuconfig" |
| Fix errors | "The build failed with [error]" |
| Setup new project | "Set up ESP-IDF for Windows" |
| Check size | "Show firmware size breakdown" |

## Common Issues

| Error | Solution |
|-------|----------|
| `MSys/Mingw is not supported` | Use `./idf.sh` instead of `idf.py` |
| `Permission denied: ./idf.sh` | `chmod +x ./idf.sh` |
| `idf.sh not found` | Copy from template (see setup above) |
| `export.ps1 not found` | Edit `idf.sh` and update IDF_EXPORT_SCRIPT path |
| PowerShell execution policy | Run in PowerShell as Admin: `Set-ExecutionPolicy RemoteSigned` |

## File Locations

```
your-project/
├── .claude/skills/build-with-esp-idf/    # This skill
├── idf.sh                                 # Wrapper script (REQUIRED)
├── build-claude/                          # Build output
├── CMakeLists.txt                         # Project config
└── main/                                  # Your code
    ├── CMakeLists.txt
    └── main.c (or main.cpp)
```

## Build Output

All build artifacts are in `build-claude/`:

```
build-claude/
├── your-project.bin          # Flash this to device
├── your-project.elf          # Debug symbols
├── bootloader/bootloader.bin
├── partition_table/partition-table.bin
└── flash_args                # Flash parameters
```

## Skill Files

```
.claude/skills/build-with-esp-idf/
├── SKILL.md                      # Claude reads this
├── README.md                     # About the skill
├── WINDOWS-SETUP.md              # Detailed setup info
├── USAGE-GUIDE.md                # Usage examples
├── QUICK-REFERENCE.md            # This file
└── scripts/
    ├── idf-wrapper-template.sh   # Template for idf.sh
    └── verify-setup.sh           # Setup checker
```

## Environment Variables

The `idf.sh` wrapper removes these MSYS variables:

- `MSYSTEM`
- `MINGW_PREFIX`
- `MSYSTEM_PREFIX`
- `MSYSTEM_CHOST`
- `MSYSTEM_CARCH`

This allows ESP-IDF to run properly in PowerShell.

## Typical Workflow

1. Make code changes in your editor
2. Ask Claude: "Build and flash"
3. Claude runs: `./idf.sh -B build-claude flash monitor`
4. View serial output
5. If errors, ask Claude: "Help fix this error"
6. Repeat

## Resources

- ESP-IDF Docs: https://docs.espressif.com/projects/esp-idf/
- Windows Setup: https://docs.espressif.com/projects/esp-idf/en/stable/esp32/get-started/windows-setup.html
- Claude Code Skills: https://code.claude.com/docs/en/skills.md

## Tips

✅ **DO:**
- Use `./idf.sh` for all ESP-IDF commands
- Build to `build-claude` directory with `-B` flag
- Ask Claude for help with errors
- Run verify-setup.sh after setup

❌ **DON'T:**
- Call `idf.py` directly from Git Bash
- Mix `build/` and `build-claude/` builds
- Forget to `chmod +x idf.sh`
- Hardcode COM ports (let Claude detect)

## Getting Started

**Never used this before?** Just ask Claude:

> "Set up this ESP-IDF project for building on Windows with Claude Code"

Claude will handle everything using this skill!

---

**Version:** 1.0
**Updated:** 2024-01-XX
**Compatible with:** ESP-IDF 5.5.1+, Windows 10/11, Git Bash
