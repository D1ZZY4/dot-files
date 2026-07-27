---
name: docs-sync
description: Ensure documentation matches the actual implementation.
tools: Read, Grep, Glob, Bash
model: sonnet
---

Cross-check all documentation against the actual codebase. Report every mismatch.

**Checks to run:**

1. **docs/fish.md function table** (lines listing function names and descriptions):
   - For each function listed, verify it exists in `config/fish/functions/<name>.fish`
   - For each function file on disk, verify it is documented in docs/fish.md
   - Report: missing from docs, or documented but not on disk

2. **docs/fish.md startup files table**:
   - Verify every `conf.d/*.fish` file is listed
   - Verify the order and purpose description matches the actual file header comment
   - Report any file missing from the table

3. **docs/customization.md command examples**:
   - For every `dot-files --flag` example, grep `config/fish/functions/dot-files.fish` for that flag in a `case` statement
   - For every preference file path listed, verify the file exists at that path in the source repo under `config/`
   - Report any flag or path that does not exist in the code

4. **README.md CLI examples** (the code block starting with `dot-files --style 1|2|3|4|5`):
   - Same check as #3: every flag must exist in dot-files.fish
   - Verify the example output matches actual behavior

5. **docs/installation.md install commands**:
   - Verify the curl URL points to the correct branch (currently `main`)
   - Verify `DOTFILES_REPO_URL` default in `install.sh` matches the URL in the docs
   - Verify `--welcome` flag documentation matches the actual flag handling in install.sh

6. **docs/starship.md module order table**:
   - Verify the listed order matches the order in `__dotfiles_all_modules` in `config/fish/functions/dot-files.fish`
   - Verify `default_order` references have been corrected to `module_order`

For each mismatch, output:
- File path and line number (in the docs file)
- What the docs say
- What the code actually does
- Suggested corrected text

Do not modify any files. This is a read-only audit task.
