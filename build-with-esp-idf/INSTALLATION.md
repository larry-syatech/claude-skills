# Installation Guide: build-with-esp-idf Skill

This guide shows how to install and use the `build-with-esp-idf` skill in your ESP-IDF projects.

## What Gets Installed

```
your-project/
├── .claude/
│   └── skills/
│       └── build-with-esp-idf/      ← This skill
│           ├── SKILL.md              ← Claude reads this
│           ├── README.md
│           ├── WINDOWS-SETUP.md
│           ├── USAGE-GUIDE.md
│           ├── QUICK-REFERENCE.md
│           ├── INSTALLATION.md       ← You are here
│           └── scripts/
│               ├── idf-wrapper-template.sh
│               └── verify-setup.sh
└── idf.sh                            ← Created from template
```

## Installation Options

### Option 1: Copy from This Project (Easiest)

If you already have this skill in one project and want to use it in another:

```bash
# From your new ESP-IDF project directory
NEW_PROJECT="/path/to/your/new/esp-idf-project"
THIS_PROJECT="/path/to/this/project"

cd "$NEW_PROJECT"

# Copy the entire skill
mkdir -p .claude/skills
cp -r "$THIS_PROJECT/.claude/skills/build-with-esp-idf" .claude/skills/

# Set up the wrapper script
cp .claude/skills/build-with-esp-idf/scripts/idf-wrapper-template.sh ./idf.sh
chmod +x ./idf.sh

# Edit idf.sh to set your ESP-IDF path
# Update the IDF_EXPORT_SCRIPT line
nano ./idf.sh  # or vim, or any editor

# Verify setup
.claude/skills/build-with-esp-idf/scripts/verify-setup.sh

# Test
./idf.sh --version
```

### Option 2: Install Globally (For All Projects)

Make the skill available to ALL your ESP-IDF projects:

```bash
# Create global skills directory
mkdir -p ~/.claude/skills

# Copy the skill
cp -r .claude/skills/build-with-esp-idf ~/.claude/skills/

# Now in ANY project, just create idf.sh:
cd /path/to/any/esp-idf/project
cp ~/.claude/skills/build-with-esp-idf/scripts/idf-wrapper-template.sh ./idf.sh
chmod +x ./idf.sh
# Edit idf.sh to set ESP-IDF path
```

**Advantages:**
- Available in all projects automatically
- Single source of truth for updates
- Easier to maintain

**Disadvantages:**
- Not version-controlled with your project
- Team members need to install separately
- May not work if they have different ESP-IDF versions

### Option 3: Add to Project Template (For Teams)

Create an ESP-IDF project template with the skill pre-installed:

```bash
# Create a template directory
mkdir ~/esp-idf-project-template
cd ~/esp-idf-project-template

# Copy your project structure
cp -r /path/to/this/project/.claude .
cp /path/to/this/project/idf.sh .
# ... copy other template files (CMakeLists.txt, etc.)

# When creating new projects:
cp -r ~/esp-idf-project-template /path/to/new-project
cd /path/to/new-project
# Edit idf.sh for local ESP-IDF path
# Start coding!
```

## Post-Installation Setup

After installing the skill, configure `idf.sh` for your system:

### 1. Find Your ESP-IDF Installation

```bash
# Common locations:
ls "C:\Users\$USERNAME\esp\v5.5.1\esp-idf\export.ps1"
ls "C:\Espressif\frameworks\esp-idf-v5.5.1\export.ps1"

# Or check IDF_PATH if set
echo $IDF_PATH
```

### 2. Edit idf.sh

Open `./idf.sh` in your editor and update line ~22:

```bash
# Before:
IDF_EXPORT_SCRIPT="C:\Users\Larry\esp\v5.5.1\esp-idf\export.ps1"

# After (your actual path):
IDF_EXPORT_SCRIPT="C:\Users\YourUsername\esp\v5.5.1\esp-idf\export.ps1"
```

### 3. Verify Installation

```bash
# Run verification script
.claude/skills/build-with-esp-idf/scripts/verify-setup.sh

# Should output:
# ✓ OK: idf.sh exists
# ✓ OK: export.ps1 file exists at configured path
# ... etc
```

### 4. Test Build

```bash
# Try a simple command
./idf.sh --version

# Should output something like:
# ESP-IDF v5.5.1

# Try building (if you have a project)
./idf.sh -B build-claude build
```

## Activating the Skill in Claude Code

The skill is loaded when Claude Code starts. After installation:

1. **Exit Claude Code** (if running)
2. **Restart Claude Code** in your project directory
3. **Verify the skill is loaded:**
   - Ask Claude: "What skills are available?"
   - Should list `build-with-esp-idf`

4. **Test it:**
   - Ask Claude: "Build this ESP-IDF project"
   - Claude should use `./idf.sh` automatically

## Updating the Skill

To update the skill to a newer version:

### For Project-Level Installation

```bash
# Get the new version
cd /path/to/project/with/new/version

# Copy to your project
cp -r .claude/skills/build-with-esp-idf /path/to/your/project/.claude/skills/

# Restart Claude Code
```

### For Global Installation

```bash
# Update the global copy
cp -r /path/to/new/version/.claude/skills/build-with-esp-idf ~/.claude/skills/

# Restart Claude Code in all projects
```

## Uninstalling

### Remove from Single Project

```bash
# Remove skill
rm -rf .claude/skills/build-with-esp-idf

# Optionally remove wrapper script
rm ./idf.sh

# Restart Claude Code
```

### Remove Global Installation

```bash
# Remove global skill
rm -rf ~/.claude/skills/build-with-esp-idf

# idf.sh in each project still works, but Claude won't use the skill
```

## Troubleshooting Installation

### Skill Not Appearing

**Problem:** Claude doesn't recognize the skill

**Solutions:**
1. Check location: `ls .claude/skills/build-with-esp-idf/SKILL.md`
2. Check YAML frontmatter in SKILL.md (lines 1-5)
3. Restart Claude Code completely
4. Ask Claude: "List all available skills"

### YAML Frontmatter Errors

**Problem:** Skill fails to load due to YAML errors

**Solution:** Verify SKILL.md starts with:
```yaml
---
name: build-with-esp-idf
description: Configures and builds ESP-IDF projects...
allowed-tools: Bash, Read, Write, Edit, Glob, Grep
---
```

- Must start with `---` on line 1
- Must end with `---` before content
- No tabs, only spaces for indentation
- No special characters in name (lowercase, hyphens only)

### idf.sh Not Working

**Problem:** `./idf.sh build` fails

**Solutions:**
1. Make executable: `chmod +x ./idf.sh`
2. Verify path in idf.sh is correct
3. Test ESP-IDF: Check if export.ps1 exists
4. Run verification: `.claude/skills/build-with-esp-idf/scripts/verify-setup.sh`

### PowerShell Errors

**Problem:** PowerShell execution policy errors

**Solution:** Run in PowerShell as Administrator:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## Sharing with Team

### Via Git (Recommended)

```bash
# Commit the skill to your repository
git add .claude/skills/build-with-esp-idf/
git add idf.sh
git commit -m "Add build-with-esp-idf skill for Claude Code"
git push

# Team members clone and use:
git clone <your-repo>
cd <your-repo>
chmod +x ./idf.sh
# Edit idf.sh for their ESP-IDF path
# Start Claude Code
# Ask: "Build this project"
```

### Via Archive

```bash
# Create archive
cd your-project
tar czf esp-idf-skill.tar.gz .claude/skills/build-with-esp-idf/ idf.sh

# Send to team member
# They extract in their project:
cd their-project
tar xzf esp-idf-skill.tar.gz
chmod +x ./idf.sh
# Edit idf.sh for their system
```

### Via Documentation

Add to your project's README.md:

```markdown
## Building with Claude Code

This project includes a Claude Code skill for ESP-IDF builds on Windows.

### Setup

1. Ensure `idf.sh` is executable: `chmod +x ./idf.sh`
2. Edit `idf.sh` and update the ESP-IDF path (line ~22)
3. Verify: `.claude/skills/build-with-esp-idf/scripts/verify-setup.sh`
4. Start Claude Code and ask: "Build this project"

See `.claude/skills/build-with-esp-idf/README.md` for details.
```

## Next Steps

After installation:

1. **Read the Quick Reference:**
   ```bash
   cat .claude/skills/build-with-esp-idf/QUICK-REFERENCE.md
   ```

2. **Try a build:**
   Ask Claude: "Build this ESP-IDF project"

3. **Explore the Usage Guide:**
   ```bash
   cat .claude/skills/build-with-esp-idf/USAGE-GUIDE.md
   ```

4. **Customize if needed:**
   Edit `SKILL.md` to add project-specific instructions

## Support

If you encounter issues:

1. Run verification: `.claude/skills/build-with-esp-idf/scripts/verify-setup.sh`
2. Check WINDOWS-SETUP.md for detailed troubleshooting
3. Ask Claude: "Help me troubleshoot the ESP-IDF build setup"
4. Check Claude Code documentation: https://code.claude.com/docs/

## Version History

- **v1.0** (2024-12-31): Initial release
  - Windows Git Bash support
  - ESP-IDF 5.5.1 compatibility
  - Verification script
  - Comprehensive documentation

---

**Ready to build?** Ask Claude: "Build this ESP-IDF project"
