---
name: deep-research
description: |
  Provides guidance for comprehensive deep research tasks including information gathering,
  code/architecture exploration, and technical problem solving. Use when asked to perform 
  a deep dive, deep research, or deep investigation on a codebase, search, issue, or problem, 
  or when asked to learn about or teach the user about a concept, technology, or codebase.
allowed-tools: Read, Grep, Glob, WebFetch, WebSearch, Task
---

# Deep Research Skill

This skill provides guidance for conducting thorough, well-documented research across any domain—whether investigating codebases, exploring web resources, or solving technical problems.

## Core Research Principles

### 1. Verify Before Trusting

- **Cross-reference claims**: Never rely on a single source. Validate findings against official documentation, multiple articles, or the actual code.
- **Check freshness**: Note publication dates. Technology moves fast—information from 2+ years ago may be outdated.
- **Prefer primary sources**: Official docs, source code, and API references over blog posts and Stack Overflow answers.
- **Be skeptical of generated content**: AI-generated content may contain hallucinations. Verify against authoritative sources.

### 2. Breadth Then Depth

- **Survey first**: Before diving deep, scan the landscape. What are the main approaches? Who are the key authors/maintainers? What are the common pitfalls?
- **Identify promising leads**: Note which sources seem most authoritative or relevant.
- **Then go deep**: Once you've mapped the territory, drill into the most promising areas.
- **Track dead ends**: Document approaches that didn't pan out—this is valuable information too.

### 3. Know When to Stop

- **Diminishing returns**: If the last 3 searches yielded no new information, it's time to synthesize what you have.
- **Ask for direction**: When stuck or facing multiple valid paths, present options to the user rather than guessing.
- **Partial findings are valuable**: Don't wait for complete answers. Share what you've found and what remains unknown.
- **Time-box exploration**: Set implicit boundaries. Comprehensive doesn't mean infinite.

## Research Process Guidelines

### Information Gathering

When gathering information, search for information in a structured way. Break down complex research tasks systematically.Track your confidence levels in your progress notes to improve calibration.  Regularly self-critique your approach and plan. 

Use these approaches based on the research type:

**For codebase research:**
1. Start with structure exploration (Glob for file patterns, directory structure)
2. Search for key terms and patterns (Grep for implementations, usages)
3. Read relevant files to understand context and connections
4. Build a mental map of how components relate

**For web research:**
1. Begin with broad searches to understand the landscape
2. Identify authoritative sources (official docs, reputable publications)
3. Fetch and analyze key pages for detailed information
4. Cross-reference findings across multiple sources

**For problem-solving research:**
1. Reproduce and understand the problem clearly
2. Search for similar issues and known solutions
3. Investigate root causes through code and documentation
4. Evaluate potential solutions before recommending
5. Regularly self-critique your approach and plan
6. Update a hypothesis tree or research notes file to persist information and provide transparency

### Critical Analysis

Apply critical thinking throughout:

- **Evaluate credibility**: Is this source authoritative? Is the author qualified?
- **Compare conflicting info**: When sources disagree, investigate why. Note the conflict.
- **Note limitations**: What doesn't this source cover? What assumptions does it make?
- **Consider context**: Does this apply to the user's situation (version, platform, use case)?

### Source Citation

Always cite your sources:

- **Web sources**: Provide URLs and note the date accessed if content may change
- **Code references**: Cite file paths and line numbers (e.g., `src/auth/login.ts:45`)
- **Documentation**: Reference specific doc pages or sections
- **Distinguish speculation**: Clearly mark inferences vs. established facts

## Output Guidelines

Adapt your output format to the research type and user needs:

**For quick questions:**
- Lead with the direct answer
- Follow with supporting evidence
- Cite sources inline

**For exploratory research:**
- Start with key findings summary
- Provide detailed analysis sections
- Include a sources list at the end

**For problem investigations:**
- State the problem clearly
- Present root cause analysis
- Recommend solutions with trade-offs
- Note any remaining unknowns

**For comprehensive deep dives:**
- Executive summary of findings
- Detailed sections by topic
- Analysis and recommendations
- Limitations and gaps
- Full source citations

## Anti-Patterns to Avoid

- **Single-source conclusions**: Always verify with at least one additional source
- **Outdated information**: Check dates and version numbers
- **Unverified assumptions**: State assumptions explicitly and validate when possible
- **Information overload**: Synthesize and summarize—don't dump raw findings
- **Speculation as fact**: Clearly distinguish between what you know and what you infer
- **Ignoring contradictions**: Address conflicting information directly
- **Premature conclusions**: Gather sufficient evidence before drawing conclusions

## Example Research Scenarios

### Scenario 1: Understanding an Unfamiliar Codebase

User: "Research how authentication works in this project"

Approach:
1. Search for auth-related files: `Glob **/*auth*`, `Grep "login|authenticate|session"`
2. Read key files to understand the flow
3. Map the authentication journey (entry points, middleware, token handling)
4. Document findings with file references
5. Note any security considerations observed

### Scenario 2: Investigating a Technical Problem

User: "Research why our API calls are failing intermittently"

Approach:
1. Search for error handling and API client code
2. Look for timeout, retry, and connection pooling configurations
3. Research common causes of intermittent API failures
4. Cross-reference with the specific libraries/frameworks in use
5. Present likely causes ranked by probability with investigation steps

### Scenario 3: Learning About a New Technology

User: "Research WebAssembly and how we might use it"

Approach:
1. Web search for current state of WebAssembly (capabilities, limitations)
2. Fetch official documentation for core concepts
3. Research use cases relevant to the user's context
4. Find examples of similar projects using WASM
5. Summarize with practical recommendations and next steps
