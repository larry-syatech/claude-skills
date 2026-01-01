# Contributing to SyaTech Claude Code Skills

Thank you for contributing! This guide will help you create high-quality skills for the team.

## Table of Contents

- [Getting Started](#getting-started)
- [Creating a New Skill](#creating-a-new-skill)
- [Skill Anatomy](#skill-anatomy)
- [Best Practices](#best-practices)
- [Testing Your Skill](#testing-your-skill)
- [Submitting Your Skill](#submitting-your-skill)

## Getting Started

1. **Fork or clone the repository**:
   ```bash
   git clone https://github.com/larry-syatech/claude-skills.git
   cd claude-skills
   ```

2. **Create a branch for your skill**:
   ```bash
   git checkout -b skill/your-skill-name
   ```

3. **Develop and test your skill** (see sections below)

4. **Submit a pull request**

## Creating a New Skill

### 1. Choose a Skill Name

- Use lowercase with hyphens: `my-skill-name`
- Maximum 64 characters
- Be descriptive but concise
- Avoid names that conflict with existing skills

### 2. Create the Skill Directory

```bash
mkdir your-skill-name
cd your-skill-name
```

### 3. Create SKILL.md (Required)

This is the main file Claude Code reads:

```yaml
---
name: your-skill-name
description: |
  Clear, concise description of what this skill does.
  Include specific trigger terms users would say.
  Example: "Use when configuring X, running Y commands, or troubleshooting Z"
allowed-tools: Read, Grep, Bash  # Optional: restrict which tools Claude can use
model: claude-sonnet-4           # Optional: override default model
---

# Your Skill Name

Brief overview of the skill's purpose.

## When to Use This Skill

- Specific scenario 1
- Specific scenario 2
- Specific scenario 3

## Instructions for Claude

Clear, step-by-step instructions:

1. First, do X
2. Then, check Y
3. If condition Z, do A, otherwise do B

## Examples

### Example 1: Basic Usage

User: "Do task X"

Expected behavior:
1. Step 1...
2. Step 2...

### Example 2: Advanced Usage

User: "Complex task with parameters"

Expected behavior:
1. Parse parameters
2. Execute with options

## Common Pitfalls

- Warn about X
- Watch out for Y
- Remember to Z

## Related Files

- For detailed reference, see [reference.md](reference.md)
- For templates, see [templates/](templates/)
```

### 4. Create README.md (Optional but Recommended)

User-facing documentation:

```markdown
# Your Skill Name

Brief description for users.

## Installation

\`\`\`bash
# Project installation
cp -r ~/claude-skills/your-skill-name .claude/skills/

# Global installation
cp -r ~/claude-skills/your-skill-name ~/.claude/skills/
\`\`\`

## Usage

How users invoke and interact with this skill.

## Examples

Real-world examples of the skill in action.

## Requirements

Any prerequisites (tools, environment variables, etc.)

## Troubleshooting

Common issues and solutions.
```

### 5. Add Supporting Files (Optional)

```
your-skill-name/
├── SKILL.md              # Required
├── README.md             # Recommended
├── scripts/              # Optional: helper scripts
│   ├── setup.sh
│   └── verify.sh
├── templates/            # Optional: template files
│   └── config-template.txt
└── reference.md          # Optional: detailed reference
```

## Skill Anatomy

### The `description` Field (Critical!)

This is **the most important part** of your skill. Claude uses it to decide when to invoke the skill.

**Good descriptions**:
```yaml
description: |
  Configures ESP-IDF projects on Windows using Git Bash.
  Use when: building ESP32 firmware, flashing ESP-IDF projects,
  running idf.py commands, troubleshooting MSYS/Mingw build errors.
```

**Bad descriptions**:
```yaml
description: "Helps with ESP stuff"  # Too vague!
```

**Include**:
- What the skill does (action verbs)
- When to use it (trigger scenarios)
- Specific keywords users might say
- Technologies/tools involved

### The `allowed-tools` Field (Security)

Restrict which tools Claude can use within your skill:

```yaml
# Read-only access
allowed-tools: Read, Grep, Glob

# File operations
allowed-tools: Read, Write, Edit

# Bash with restrictions
allowed-tools: Bash(git:*), Bash(npm:*), Read, Write

# Full access (default if omitted)
allowed-tools: "*"
```

### Progressive Disclosure

Keep `SKILL.md` under 500 lines. For complex skills, split into multiple files:

```yaml
---
name: complex-skill
---

# Complex Skill

## Quick Start
Essential instructions here...

## Detailed Reference
For advanced usage, see [reference.md](reference.md)
```

Claude will load `reference.md` only when needed, keeping context usage efficient.

## Best Practices

### 1. Be Specific and Actionable

**Good**:
```markdown
## Instructions

1. Check if package.json exists using Read tool
2. If found, parse the "scripts" section
3. Run `npm test` using Bash tool
4. If tests fail, report error details to user
```

**Bad**:
```markdown
## Instructions

Help the user with testing.
```

### 2. Include Trigger Terms

Think about what users will actually say:

```yaml
description: |
  Analyzes Python code for PEP 8 compliance.
  Use when: checking Python style, linting code,
  fixing formatting issues, running flake8 or black.
```

### 3. Provide Examples

Show Claude exactly what good execution looks like:

```markdown
## Examples

### Example 1: Successful Build

User: "Build the project"

Expected flow:
1. Run: `./idf.sh -B build-claude build`
2. Wait for completion
3. Report: "Build successful! Binary at build-claude/project.bin"

### Example 2: Build Failure

User: "Build the project"

Expected flow:
1. Run: `./idf.sh -B build-claude build`
2. Detect error in output
3. Analyze error message
4. Suggest fix: "Missing dependency X. Run: pip install X"
```

### 4. Handle Errors Gracefully

Teach Claude to handle failure scenarios:

```markdown
## Error Handling

If command fails:
1. Capture error output
2. Check for common issues:
   - Missing dependencies → suggest installation
   - Permission errors → suggest chmod/sudo
   - Path errors → verify paths exist
3. Provide actionable fix to user
```

### 5. Version Control

Include version information:

```yaml
---
name: your-skill
version: "1.0.0"
changelog: |
  v1.0.0 (2025-01-01): Initial release
---
```

Update version on changes:
- Major (1.x.x): Breaking changes
- Minor (x.1.x): New features, backward compatible
- Patch (x.x.1): Bug fixes

## Testing Your Skill

### 1. Local Testing

Install to a test project:

```bash
# In your test project
mkdir -p .claude/skills
cp -r ~/claude-skills/your-skill-name .claude/skills/

# Open Claude Code in that project
# Test various trigger phrases
```

### 2. Test Cases

Create a test checklist:

- [ ] Skill activates on expected trigger terms
- [ ] Skill performs the task correctly
- [ ] Error handling works (test failure scenarios)
- [ ] Documentation is clear
- [ ] No security issues (if using Bash, test with restricted tools)

### 3. Example Test Session

```
User: "run the build"
✓ Skill activates: build-with-esp-idf
✓ Detects project type correctly
✓ Runs appropriate build command
✓ Reports result to user

User: "the build failed"
✓ Skill offers troubleshooting
✓ Analyzes error output
✓ Suggests actionable fix
```

## Submitting Your Skill

### 1. Pre-Submission Checklist

- [ ] `SKILL.md` exists with proper frontmatter
- [ ] `README.md` exists with installation/usage docs
- [ ] Description includes trigger terms
- [ ] Examples are clear and complete
- [ ] Tested in local Claude Code session
- [ ] No sensitive information (API keys, passwords, etc.)
- [ ] Scripts are executable (`chmod +x scripts/*.sh`)

### 2. Commit Your Changes

```bash
git add your-skill-name/
git commit -m "Add your-skill-name skill

- Brief description of what the skill does
- Any special requirements or notes
"
```

### 3. Create Pull Request

1. Push your branch:
   ```bash
   git push origin skill/your-skill-name
   ```

2. Open a pull request on GitHub

3. In the PR description, include:
   - **Purpose**: What problem this skill solves
   - **Trigger terms**: Example phrases that activate it
   - **Testing**: How you tested it
   - **Documentation**: Link to README if complex

### 4. PR Review Process

Your PR will be reviewed for:

- Clarity of instructions
- Quality of documentation
- Security (especially if using Bash tool)
- Usefulness to the team
- No conflicts with existing skills

## Style Guide

### Markdown Formatting

- Use ATX-style headers (`#`, `##`, `###`)
- Code blocks should specify language (` ```bash `)
- Use bullet lists for items without sequence
- Use numbered lists for sequential steps

### Voice and Tone

- Write in **imperative mood** for instructions ("Run the command", not "You should run")
- Be **concise but complete**
- Use **active voice** ("Check the file" not "The file should be checked")
- **Anticipate questions** and answer them preemptively

### Examples Format

Always include:
1. User input (what triggers the skill)
2. Expected behavior (what Claude should do)
3. Success criteria (what indicates completion)

## Questions?

- Open an issue on GitHub
- Ask in team chat
- Email the DevTools team

---

Thank you for making our team's workflows better!
