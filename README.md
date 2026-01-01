# SyaTech Claude Code Skills

A collection of custom skills for [Claude Code](https://claude.com/claude-code) to enhance development workflows.

## What are Claude Code Skills?

Skills are custom instructions that extend Claude Code's capabilities for specific tasks. They help Claude understand your team's workflows, tools, and conventions.

## Available Skills

### build-with-esp-idf

**Purpose**: Configures and builds ESP-IDF projects on Windows using Git Bash/MSYS.

**Use when**:
- Setting up ESP32/ESP32-C6 projects
- Running idf.py commands in Git Bash (MSYS environment)
- Building firmware, flashing devices
- Troubleshooting ESP-IDF builds on Windows where MSYS/Mingw environments are not officially supported

**Key Features**:
- Automatic ESP-IDF path detection using `IDF_PATH` environment variable
- Falls back to default `~/esp/esp-idf` location
- Provides `idf.sh` wrapper script for seamless Git Bash integration
- Includes verification and setup scripts

**Documentation**: [build-with-esp-idf/README.md](build-with-esp-idf/README.md)

---

## Installation

### Option 1: Install to Current Project (Recommended)

Skills installed in `.claude/skills/` are available only within that project:

```bash
# Clone this repository
git clone https://github.com/larry-syatech/claude-skills.git ~/claude-skills

# Navigate to your project
cd /path/to/your/project

# Copy the skill you want
cp -r ~/claude-skills/build-with-esp-idf .claude/skills/
```

### Option 2: Install Globally (Personal Skills)

Skills installed in `~/.claude/skills/` are available across all your projects:

```bash
# Clone this repository
git clone https://github.com/larry-syatech/claude-skills.git ~/claude-skills

# Copy the skill to your personal skills directory
mkdir -p ~/.claude/skills
cp -r ~/claude-skills/build-with-esp-idf ~/.claude/skills/
```

### Option 3: Team Setup (Commit to Project)

For teams working in the same repository:

```bash
# In your team's repository
mkdir -p .claude/skills
cp -r ~/claude-skills/build-with-esp-idf .claude/skills/

# Commit to version control
git add .claude/skills/build-with-esp-idf
git commit -m "Add build-with-esp-idf skill for the team"
git push

# Team members get the skill automatically on pull
git pull
```

## Usage

Once installed, skills are automatically discovered by Claude Code. You can invoke them by:

1. **Mentioning the trigger terms** in your message (e.g., "build ESP-IDF project", "flash ESP32")
2. **Using the skill name** directly: `/build-with-esp-idf`
3. **Letting Claude decide** when the task matches the skill's description

## Updating Skills

```bash
# Update your local clone
cd ~/claude-skills
git pull

# Copy the updated skill
cp -r ~/claude-skills/build-with-esp-idf .claude/skills/
# or for global installation:
cp -r ~/claude-skills/build-with-esp-idf ~/.claude/skills/
```

## Contributing

We welcome contributions! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on:
- Creating new skills
- Improving existing skills
- Documentation standards
- Testing requirements

## Skill Development Guidelines

### Skill Structure

Each skill should follow this structure:

```
skill-name/
├── SKILL.md              # Required: Main skill instructions
├── README.md             # Optional: User-facing documentation
├── scripts/              # Optional: Helper scripts
│   └── helper.sh
└── templates/            # Optional: Template files
    └── template.txt
```

### SKILL.md Format

```yaml
---
name: skill-identifier
description: |
  Clear description of what this skill does.
  Include trigger terms users might say.
allowed-tools: Read, Grep, Bash  # Optional: restrict tools
---

# Skill Name

## Instructions
Step-by-step guidance for Claude Code.

## Examples
Concrete usage examples.
```

**Important**: The `description` field is how Claude decides when to use the skill. Include specific actions AND trigger terms.

## Resources

- [Claude Code Documentation](https://code.claude.com/docs/)
- [Skills Documentation](https://code.claude.com/docs/en/skills.md)
- [Official Skills Examples](https://github.com/anthropics/skills)

## License

MIT License - See [LICENSE](LICENSE) for details.

## Support

For issues or questions:
- Open an issue on GitHub
- Contact the DevTools team at SyaTech

---

**Built with** ❤️ **by the SyaTech team**
