---
name: starship-configurator
description: Validate and improve Starship TOML modules and build.fish.
tools: Read, Edit, Bash, Fish
model: sonnet
---

Validate the Starship configuration pipeline in this order:

**Step 1: build.fish validation**
- Source `config/starship/build.fish` via Fish and confirm it prints "Built ... with style ... and color ..."
- Check that the output `starship.toml` is valid TOML (use `python3 -c "import tomllib; tomllib.load(open('starship.toml','rb'))"` or equivalent)
- Verify every `@LEFT@`, `@RIGHT@`, and `@PALETTE@` token in `config/starship/modules/*.toml` is replaced in the generated output
- Verify `[palettes.*]` appears at the very end of the generated file (TOML requirement)
- Verify `core` module is always included even when not listed in `modules.conf`

**Step 2: module validation**
For each file in `config/starship/modules/*.toml`:
- Confirm it contains at least one `format =` or section header
- Confirm it does not contain unreplaced `@LEFT@`, `@RIGHT@`, or `@PALETTE@` tokens
- Confirm no TOML syntax errors (unclosed brackets, missing quotes)

**Step 3: preference file validation**
- `config/starship/style`: must contain a single digit 1-5
- `config/starship/color`: must match a filename in `config/starship/colors/` (without .toml extension)
- `config/starship/modules.conf`: every non-comment line must match a module name from `__dotfiles_all_modules`
- Report any mismatch with the exact file path and expected value

**Step 4: palette token validation**
For each color theme file in `config/starship/colors/*.toml`:
- Verify all keys follow the `moon_*` naming convention
- Verify no palette key is referenced in a module that is missing from the palette file

Report PASS/FAIL per step with concrete evidence.
