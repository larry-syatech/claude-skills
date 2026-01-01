# build-with-esp-idf Skill

A Claude Code skill for configuring and building ESP-IDF projects on Windows using Git Bash/MSYS environments.

## What This Skill Does

This skill helps Claude Code work with ESP-IDF projects on Windows. ESP-IDF 5.0+ doesn't officially support MSYS/Mingw (which Claude Code uses), so this skill provides:

1. Instructions for using the `idf.sh` wrapper script
2. Templates and setup scripts for new ESP-IDF projects
3. Troubleshooting guidance for common build issues
4. Best practices for Windows + Git Bash + ESP-IDF development

## Quick Start

### For Existing Projects (Already Have idf.sh)

The skill is automatically available. Claude will use it when you ask about:
- Building ESP-IDF projects
- Running idf.py commands
- Flashing or monitoring devices
- Troubleshooting ESP-IDF builds on Windows

### For New Projects (Need to Set Up)

1. **Copy the wrapper script template**
   ```bash
   cp .claude/skills/build-with-esp-idf/scripts/idf-wrapper-template.sh ./idf.sh
   chmod +x ./idf.sh
   ```

2. **Edit idf.sh** to update the ESP-IDF path:
   ```bash
   # Edit this line to match your ESP-IDF installation
   IDF_EXPORT_SCRIPT="C:\Users\YourUsername\esp\v5.5.1\esp-idf\export.ps1"
   ```

3. **Verify setup**
   ```bash
   .claude/skills/build-with-esp-idf/scripts/verify-setup.sh
   ```

4. **Build your project**
   ```bash
   ./idf.sh -B build-claude build
   ```

## Skill Files

```
build-with-esp-idf/
├── SKILL.md                        # Main skill instructions (read by Claude)
├── README.md                       # This file (for humans)
├── WINDOWS-SETUP.md                # Detailed Windows setup reference
└── scripts/
    ├── idf-wrapper-template.sh     # Template for idf.sh wrapper
    └── verify-setup.sh             # Setup verification script
```

## How Claude Uses This Skill

When you ask Claude to:
- "Build this ESP32 project"
- "Flash the firmware to my ESP32-C6"
- "Configure the ESP-IDF project"
- "Help me set up ESP-IDF builds on Windows"

Claude automatically reads `SKILL.md` and applies the instructions, ensuring it:
- Uses `./idf.sh` instead of direct `idf.py` calls
- Targets the `build-claude` directory
- Provides correct troubleshooting steps

## Using This Skill in Other Projects

### Option 1: Copy to Another Project (Recommended)

Copy the entire `.claude/skills/` directory to your other ESP-IDF project:

```bash
# From your other project directory
cp -r /path/to/this/project/.claude /path/to/other/project/

# Then set up idf.sh for that project
cd /path/to/other/project
cp .claude/skills/build-with-esp-idf/scripts/idf-wrapper-template.sh ./idf.sh
chmod +x ./idf.sh
# Edit idf.sh to set correct IDF_EXPORT_SCRIPT path
```

### Option 2: Install Globally (Advanced)

To make this skill available for ALL your projects:

```bash
# Copy to your personal Claude skills directory
mkdir -p ~/.claude/skills/
cp -r .claude/skills/build-with-esp-idf ~/.claude/skills/

# Now it's available in any project you work on with Claude Code
```

**Note:** If you install globally, you still need to create `idf.sh` in each project.

## Troubleshooting

### "Skill not found" or Claude doesn't use it

1. Restart Claude Code after creating/modifying the skill
2. Check that `SKILL.md` has valid YAML frontmatter
3. Verify the skill directory is in `.claude/skills/build-with-esp-idf/`

### "Permission denied" on scripts

```bash
chmod +x .claude/skills/build-with-esp-idf/scripts/*.sh
```

### Claude suggests running `idf.py` directly

Remind Claude: "Use the idf.sh wrapper as described in the build-with-esp-idf skill"

## Customization

You can customize this skill for your team:

1. **Edit SKILL.md** to add project-specific build instructions
2. **Update idf-wrapper-template.sh** to change default ESP-IDF path
3. **Modify verify-setup.sh** to check for project-specific requirements

## Resources

- [ESP-IDF Documentation](https://docs.espressif.com/projects/esp-idf/)
- [Claude Code Skills Documentation](https://code.claude.com/docs/en/skills.md)
- [ESP-IDF Windows Setup](https://docs.espressif.com/projects/esp-idf/en/stable/esp32/get-started/windows-setup.html)

## Version

- **Skill Version:** 1.0
- **Compatible with:** ESP-IDF 5.5.1+
- **Tested on:** Windows 11, Git Bash (MINGW64)
- **Created for:** Claude Code CLI

## License

This skill is provided as-is for use with Claude Code and ESP-IDF development.
