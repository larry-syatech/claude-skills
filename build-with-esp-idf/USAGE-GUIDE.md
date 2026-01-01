# Usage Guide: build-with-esp-idf Skill

## For ESP-IDF Project Developers

This guide shows how to use the `build-with-esp-idf` Claude Code skill in your daily workflow.

## Common Scenarios

### Scenario 1: Building Your Project

**Just ask Claude:**

> "Build this ESP32 project"

Claude will automatically:
1. Recognize this is an ESP-IDF project
2. Use the `build-with-esp-idf` skill
3. Run: `./idf.sh -B build-claude build`
4. Report any build errors

**What happens behind the scenes:**
- Claude reads `SKILL.md` which tells it to use `./idf.sh` instead of `idf.py`
- Uses the `build-claude` directory to keep builds separate
- Handles MSYS/Mingw compatibility issues automatically

---

### Scenario 2: Flashing and Monitoring

**Just ask Claude:**

> "Flash the firmware and open the serial monitor"

Claude will run: `./idf.sh -B build-claude flash monitor`

**Or be more specific:**

> "Flash to COM4 and monitor output"

Claude will run: `./idf.sh -B build-claude -p COM4 flash monitor`

---

### Scenario 3: Configuring Your Project

**Just ask Claude:**

> "Open the ESP-IDF configuration menu"

Claude will run: `./idf.sh -B build-claude menuconfig`

**Or ask for specific changes:**

> "Enable Bluetooth in the configuration"

Claude will:
1. Run `./idf.sh -B build-claude menuconfig` (if interactive)
2. Or directly modify `sdkconfig` if it knows the setting

---

### Scenario 4: Clean Build

**Just ask Claude:**

> "Do a clean build"

Claude will run:
```bash
./idf.sh -B build-claude fullclean
./idf.sh -B build-claude build
```

---

### Scenario 5: Analyzing Binary Size

**Just ask Claude:**

> "Show me the firmware size breakdown"

Claude will run: `./idf.sh -B build-claude size-components`

---

### Scenario 6: Setting Up a New Project

**Just ask Claude:**

> "Set up this ESP-IDF project for Claude Code builds on Windows"

Claude will:
1. Copy `idf-wrapper-template.sh` to `./idf.sh`
2. Make it executable
3. Ask you to verify the ESP-IDF installation path
4. Run the verification script
5. Create/update documentation (CLAUDE.md, BUILD-CLAUDE-CODE.md)

---

### Scenario 7: Troubleshooting Build Issues

**Just ask Claude:**

> "The build failed with [error]. How do I fix it?"

Claude will:
1. Read the error
2. Consult the troubleshooting section in `SKILL.md`
3. Suggest fixes based on common ESP-IDF issues
4. May run verification script to diagnose setup problems

---

## Advanced Usage

### Customizing Build Commands

**Ask Claude to run specific commands:**

> "Run idf.py with verbose output"

Claude will run: `./idf.sh -B build-claude -v build`

> "Show me the current ESP-IDF configuration"

Claude will run: `./idf.sh -B build-claude show-env`

### Working with Multiple Build Directories

**Switch between build directories:**

> "Build with the default build directory instead of build-claude"

Claude will run: `./idf.sh build` (without `-B` flag)

**Compare builds:**

> "Compare the size of build/ and build-claude/ binaries"

Claude will:
1. Run `ls -lh build/*.bin`
2. Run `ls -lh build-claude/*.bin`
3. Show the comparison

### Debugging Build Issues

**Get detailed build logs:**

> "Build with verbose output and show me the compilation commands"

Claude will run: `./idf.sh -B build-claude -v build`

**Check build configuration:**

> "What compiler flags are being used?"

Claude will check `build-claude/compile_commands.json` or CMake cache

---

## Tips for Working with Claude

### Be Specific When Needed

Instead of:
> "Build it"

Try:
> "Build the ESP32 project using the build-claude directory"

### Ask for Explanations

> "Explain what the idf.sh wrapper script does"

Claude will explain the MSYS/PowerShell workaround based on `WINDOWS-SETUP.md`

### Request Documentation Updates

> "Update CLAUDE.md to include these new build instructions"

Claude will edit the documentation to reflect new steps

### Ask for Best Practices

> "What's the best way to organize my ESP-IDF project?"

Claude can consult ESP-IDF documentation and suggest practices

---

## What Claude CAN Do (with this skill)

✅ Build ESP-IDF projects using `./idf.sh`
✅ Flash firmware to devices
✅ Monitor serial output
✅ Configure project settings
✅ Analyze binary sizes
✅ Troubleshoot build errors
✅ Set up new projects with `idf.sh` wrapper
✅ Update project documentation
✅ Explain ESP-IDF concepts
✅ Modify source code and configuration files

## What Claude CANNOT Do

❌ Open graphical `menuconfig` interface (it runs in terminal)
❌ Physically connect to your device
❌ Press buttons on your hardware
❌ Fix hardware-level issues
❌ Modify your ESP-IDF installation
❌ Install ESP-IDF for you

---

## Examples from Real Usage

### Example 1: First-Time Setup

**You:**
> "I just cloned this ESP-IDF project. Help me set it up to build with Claude Code on Windows."

**Claude:**
> I'll help you set up this ESP-IDF project for building with Claude Code. Let me check if the idf.sh wrapper exists...
>
> [Runs verification script]
>
> I see you need to set up the idf.sh wrapper. Let me copy the template...
>
> [Copies idf-wrapper-template.sh to ./idf.sh]
>
> Now I need you to verify the ESP-IDF installation path. Please check if this path is correct:
> `C:\Users\Larry\esp\v5.5.1\esp-idf\export.ps1`
>
> If not, please provide the correct path to your ESP-IDF installation.

### Example 2: Build Error

**You:**
> "The build failed. Here's the error: [paste error]"

**Claude:**
> I see the error is about a missing header file. This typically means:
>
> 1. The component isn't included in your CMakeLists.txt
> 2. The header path is incorrect
>
> Let me check your main/CMakeLists.txt...
>
> [Reads CMakeLists.txt]
>
> I found the issue. You're missing the `REQUIRES` entry for the wifi component. Let me fix that...
>
> [Edits CMakeLists.txt]
>
> Now let's rebuild:
>
> [Runs: ./idf.sh -B build-claude build]
>
> Build succeeded! The binary is ready at build-claude/your-project.bin

### Example 3: Optimization

**You:**
> "The firmware is too large. Help me reduce the size."

**Claude:**
> Let me analyze the firmware size breakdown...
>
> [Runs: ./idf.sh -B build-claude size-components]
>
> I see that Bluetooth is taking up 180KB but you're not using it in your code. Would you like me to:
>
> 1. Disable Bluetooth in menuconfig
> 2. Enable compiler optimizations for size
> 3. Remove unused components
>
> Which approach would you prefer?

---

## Integration with Your Workflow

### Daily Development

1. **Morning:** Clone project, ask Claude to set up build environment
2. **Development:** Make code changes, ask Claude to build and flash
3. **Testing:** Ask Claude to monitor serial output
4. **Debugging:** Share errors with Claude for troubleshooting
5. **End of day:** Ask Claude to commit changes if needed

### CI/CD Integration

While this skill is designed for local development, you can extract the concepts for CI:

```yaml
# .github/workflows/build.yml
- name: Build ESP-IDF project
  run: |
    # On CI, you'd use idf.py directly in PowerShell
    idf.py build
```

For Windows CI runners, you'd adapt the PowerShell commands from `idf.sh`.

---

## Getting Help

If the skill isn't working as expected:

1. **Restart Claude Code** - Skills are loaded on startup
2. **Check skill location** - Must be in `.claude/skills/build-with-esp-idf/`
3. **Verify YAML frontmatter** - `SKILL.md` must have valid YAML header
4. **Ask Claude** - "What skills are available?" to confirm it's loaded
5. **Run verification** - `.claude/skills/build-with-esp-idf/scripts/verify-setup.sh`

---

## Skill Updates

To update this skill in the future:

1. Edit the files in `.claude/skills/build-with-esp-idf/`
2. Restart Claude Code
3. Test with a simple build command

Common updates:
- Add new troubleshooting tips to `SKILL.md`
- Update `idf-wrapper-template.sh` for new ESP-IDF versions
- Enhance `verify-setup.sh` to check for more requirements

---

## Sharing with Your Team

To share this skill with teammates:

1. **Commit the skill directory:**
   ```bash
   git add .claude/skills/
   git commit -m "Add build-with-esp-idf skill for Claude Code"
   git push
   ```

2. **Document in README:**
   ```markdown
   ## Building with Claude Code

   This project includes a Claude Code skill for ESP-IDF builds on Windows.
   After cloning, ask Claude: "Set up this project for building on Windows"
   ```

3. **Teammates clone and use:**
   ```bash
   git clone <your-repo>
   # Start Claude Code, then ask:
   # "Set up this ESP-IDF project for Windows builds"
   ```

The skill is now part of your project and will help everyone on the team!
