# Deep Research Skill

A Claude Code skill that provides guidance for conducting thorough, well-documented research across codebases, web resources, and technical problem domains.

## Purpose

This skill enhances Claude Code's research capabilities by providing structured guidance on:

- **Information gathering**: Systematic approaches to exploring codebases and web resources
- **Critical analysis**: Evaluating source credibility, comparing conflicting information
- **Source citation**: Proper attribution and documentation of findings
- **Structured reporting**: Clear, organized presentation of research results

## Installation

### Project Installation (Recommended for Teams)

```bash
# Navigate to your project
cd /path/to/your/project

# Create skills directory if it doesn't exist
mkdir -p .claude/skills

# Copy the skill
cp -r ~/claude-skills/deep-research .claude/skills/
```

### Global Installation (Personal Use)

```bash
# Create global skills directory if it doesn't exist
mkdir -p ~/.claude/skills

# Copy the skill
cp -r ~/claude-skills/deep-research ~/.claude/skills/
```

## Usage

The skill activates when you ask Claude Code to:

- **Research** a topic, technology, or concept
- **Investigate** an issue, bug, or behavior
- **Deep dive** into a codebase or system
- **Find out about** or **learn about** something unfamiliar

### Example Prompts

```
"Research how the authentication system works in this project"

"Investigate why our tests are flaky"

"Deep dive into the WebSocket implementation"

"Find out about the best practices for error handling in Go"

"Learn about how this library handles concurrency"
```

## What This Skill Provides

### Core Principles

1. **Verify Before Trusting**: Cross-reference claims, prefer primary sources, check freshness
2. **Breadth Then Depth**: Survey the landscape before diving deep
3. **Know When to Stop**: Recognize diminishing returns, share partial findings

### Research Approaches

The skill guides Claude on different approaches based on research type:

- **Codebase research**: File exploration, pattern searching, reading and mapping
- **Web research**: Broad searches, authoritative source identification, cross-referencing
- **Problem-solving**: Reproduction, root cause analysis, solution evaluation

### Output Quality

Research results will include:

- Clear findings with supporting evidence
- Source citations (URLs, file paths, line numbers)
- Explicit distinction between facts and inferences
- Notes on limitations and remaining unknowns

## Tool Restrictions

This skill uses read-only tools to ensure research doesn't modify your codebase:

- `Read` - Reading files
- `Grep` - Searching file contents
- `Glob` - Finding files by pattern
- `WebFetch` - Fetching web content
- `WebSearch` - Searching the web
- `Task` - Spawning exploration agents

## Examples

### Codebase Research

**Prompt**: "Research how error handling works in this API"

**Expected output**:
- Overview of the error handling strategy
- Key files and their responsibilities (with paths)
- Error types and when they're used
- Middleware/interceptor patterns
- Recommendations or observations

### Technical Investigation

**Prompt**: "Investigate why the build is slow"

**Expected output**:
- Analysis of build configuration
- Identified bottlenecks with evidence
- Comparison with common causes
- Ranked recommendations for improvement
- Links to relevant documentation

### Technology Research

**Prompt**: "Research GraphQL and whether we should adopt it"

**Expected output**:
- Overview of GraphQL concepts
- Comparison with current approach (REST, etc.)
- Pros and cons for the specific use case
- Migration considerations
- Sources consulted

## Contributing

See [CONTRIBUTING.md](../CONTRIBUTING.md) for guidelines on improving this skill.

## License

BSD-3-Clause - See [LICENSE](../LICENSE) for details.
