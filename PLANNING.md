# PLANNING.md

> Master task list for the dot-files project.
> Every item below is written to be executed by an AI agent without ambiguity.
> Each task has: exact file paths, current state, required change, acceptance criteria.
> Do not skip tasks. Do not reorder without updating this document.

---

## Section 0: Project State Lock

**Base commit:** `3a600a0` (HEAD of main, already pushed to origin/main)
**Branch:** main
**Working tree:** clean (no uncommitted changes)

Recent history:
- `5273bc0` fix: correctness, portability, quoting, JSON escaping, and docs fixes
- `d8156d9` feat(fish): apply skill-guided improvements
- `905db8e` refactor(fish): consolidate dot-files management function (message needs one-word trim: "refactor(fish): consolidate dot-files function")
- `ef5effa` fix(fish): support NVM_DIR and already-loaded nvm

All syntax checks pass:
- `bash -n install.sh` returns 0
- `fish --command "source <each .fish file>"` returns 0 for every file under config/fish/ and config/fastfetch/

---

## Section 1: Pending Bugs (must fix before any new features)

### 1.1 starship-rebuild wrapper adds unnecessary subprocess overhead

**File:** `config/fish/functions/starship-rebuild.fish`
**Current content (line 4):** `fish "$HOME/.config/starship/build.fish"`
**Problem:** Every call to `starship-rebuild` from inside another fish script spawns a full new fish subprocess just to run one file. Five call sites in dot-files.fish and zz-fastfetch.fish each pay 5-15ms startup cost for zero logic gained.
**Required change:** Inline the one-liner. Replace each call site with `fish "$HOME/.config/starship/build.fish"` directly, or prefix with `eval` so Fish sources the file in-process.
**Acceptance:** `starship-rebuild.fish` is deleted. Every former caller runs `fish "$HOME/.config/starship/build.fish"` inline. `fish --command "source dot-files.fish"` still returns 0.

### 1.2 `__dotfiles_show_catalog` mutates live preference files 8 times

**File:** `config/fish/functions/dot-files.fish`, lines 199-219
**Current behavior:** The style preview loop (5 iterations) and color preview loop (3 iterations) each call `__dotfiles_write_style_file` / `__dotfiles_write_color_file` which writes to the live `~/.config/starship/style` and `~/.config/starship/color` files on disk. If the user hits Ctrl-C during `dot-files` (no args), the last-previewed value is left on disk as their new preference.
**Required change:** Write preview values to temp files (`$style_file.preview`, `$color_file.preview`), point `build.fish` at those temp files for the preview run, and delete them after. Or, pass style/color as environment variables that `build.fish` reads as overrides.
**Acceptance:** Running `dot-files` does not modify the contents of `~/.config/starship/style` or `~/.config/starship/color` unless the user explicitly ran `--style` or `--color`. Ctrl-C during preview leaves prefs unchanged.

### 1.3 `dev-tools.fish` uses 17 sequential `bash -c` subprocesses

**File:** `config/fastfetch/dev-tools.fish`, lines 21-35 (`__command_version`)
**Current behavior:** Each tool version check spawns `bash -c "<version_command>"`, then the tool itself (e.g. `node --version`). That is 34 subprocesses in sequence.
**Required change:** Use Fish-native `string replace -r` and `string match -r` instead of the `sed -E` patterns inside the version_command strings. Remove the `bash -c` layer entirely. Each version check becomes a single tool subprocess (the tool's own `--version` call piped through Fish builtins).
**Acceptance:** `__command_version` no longer calls `bash -c`. The `version_command` strings are simplified to Fish-native pipelines. Output of the Dev Tools block is identical.

### 1.4 `__command_version` uses `eval` (injection surface)

**File:** `config/fastfetch/dev-tools.fish`, line 27 (current)
**Already fixed in session:** Changed `eval $version_command` to `bash -c "$version_command"`.
**Residual risk:** `bash -c` is still a shell-injection vector if a version_command string is ever derived from user input.
**Required change:** Ensure all version_command strings are hardcoded literals (they already are). Add a comment in `__command_version` documenting that version_command must never be user-controlled. No functional change needed, only documentation.
**Acceptance:** A comment is present in dev-tools.fish near line 27 stating the security invariant.

---

## Section 2: Planned Features (implement in order)

### 2.1 `dot-files --edit` for all preference files

**Status:** PARTIALLY IMPLEMENTED in d8156d9 (style, color, modules, username, dev-tools)
**Remaining work:**
- Add `--edit` completion candidates: done in d8156d9.
- Hook `__dotfiles_edit_file` into the `--username` flow so `--edit username` opens the file AND applies `fastfetch-apply-welcome` on save.
- Hook `__dotfiles_edit_file` into style/color/modules flows so they rebuild after edit.
- **Acceptance:** `dot-files --edit username` opens `$EDITOR` on `~/.config/starship/username`, then runs `fastfetch-apply-welcome`. `dot-files --edit style` opens the style file, then runs `starship-rebuild` + shows prompt preview.

### 2.2 `dot-files --doctor` diagnostic command

**File:** `config/fish/functions/dot-files.fish` (new case block)
**Purpose:** Run sanity checks and report warnings or fixable issues. Does not mutate anything.

Required checks (in order):
1. `starship` is on PATH: `type -q starship`
2. `fastfetch` is on PATH: `type -q fastfetch`
3. `fish` config loads cleanly: `fish -c 'source $HOME/.config/fish/config.fish'` returns 0
4. `~/.config/starship/color` value matches a file in `~/.config/starship/colors/`
5. Every non-comment, non-blank line in `~/.config/starship/modules.conf` is present in `__dotfiles_all_modules`
6. Every key in `~/.config/starship/dev-tools.toml` under `[runtimes]`, `[packages]`, `[python]`, `[system_tools]`, `[infrastructure]` matches `__dotfiles_devtools_list`
7. `~/.config/starship/starship.toml` exists and is a symlink or regular file
8. Fastfetch config at `~/.config/fastfetch/config.jsonc` exists

Output format:
```
dot-files --doctor output:
[OK] starship is on PATH
[OK] fastfetch is on PATH
[OK] fish config loads cleanly
[WARN] color file contains "foobar" which does not match any theme in colors/
[OK] modules.conf references only known modules
[OK] dev-tools.toml keys match known tools
[OK] starship.toml exists
[FAIL] fastfetch config.jsonc not found at ~/.config/fastfetch/config.jsonc
```

**Acceptance:** Running `dot-files --doctor` prints one line per check, exits 0 if all OK, exits 1 if any FAIL. Does not write to any file.

### 2.3 `dot-files --status` — show state of installed dotfiles vs upstream

**File:** `config/fish/functions/dot-files.fish` (new case block)
**Purpose:** Detect whether the installed configs are managed by a git checkout, and if so, report whether they are up to date with upstream.

Logic:
1. Check if `$HOME/.local/share/dotfiles` exists and is a git repo (curl-based install path)
2. Check if `DOTFILES_DIR` is set and is a git repo (clone-based install path)
3. If neither: print "Installed via copy or unknown source. Cannot determine status."
4. If found: run `git -C <repo> status --short --branch` and print:
   - Branch name and ahead/behind counts
   - List of modified files
   - List of untracked files under config/
5. If repo is clean and up to date: print "Installed dotfiles are up to date."

**Acceptance:** `dot-files --status` prints a readable status block. Exits 0 when up to date, 1 when dirty or behind.

### 2.4 `dot-files --dev-tools reload` hot reload without shell restart

**File:** `config/fastfetch/dev-tools.fish` (new function `__dt_reload`)
**File:** `config/fish/functions/dot-files.fish` (new action in `--dev-tools` switch)

Current behavior: `--dev-tools toggle` edits `dev-tools.toml` but prints "changes apply on next startup".
Required: add a `reload` subcommand that re-sources `dev-tools.toml` visibility into the current session and re-renders the Dev Tools block in the current terminal.

Implementation:
- In `dev-tools.fish`, add `__dt_reload` that re-reads `dev-tools.toml` and sets a universal or session variable `__dt_config_file_mtime`. If mtime changed, re-render.
- In `dot-files.fish`, `case --dev-tools` gains `case reload` after `case toggle`: prints "Dev Tools reloaded" and calls `__dt_reload`.

**Acceptance:** `dot-files --dev-tools reload` prints "Dev Tools reloaded." Changes to visibility take effect without `exec fish`.

### 2.5 Fish `fish_user_paths` universal variable for persistent PATH

**File:** `config/fish/conf.d/15-paths.fish` (new file)
**Purpose:** Many tools (fnm, mise, asdf, cargo, go, python venvs) append to PATH at runtime. Fish provides `fish_user_paths` as a universal variable that auto-prepends to PATH on every shell start.

Content:
```fish
# Persistent PATH additions via universal variable.
# Tools like fnm, mise, cargo, go, etc. write here.
# Entries are deduplicated and prepended to PATH on shell startup.
set -q fish_user_paths; or set -U fish_user_paths
```

Also add a comment block listing the recommended PATH entries for common tools on CachyOS.

**Acceptance:** File exists at `config/fish/conf.d/15-paths.fish`. `fish --command "source config/fish/conf.d/15-paths.fish"` returns 0. The universal variable `fish_user_paths` is created if absent.

### 2.6 Starship prompt: show short git commit hash

**File:** `config/starship/modules/git.toml`
**Current format (line 6):** `format = "[...]($style)[ $symbol $branch ](fg:moon_bg0 bg:moon_teal)[ ](fg:moon_teal)"`
**Required change:** Append `$git_commit` after `$branch` inside the same format string, e.g.:
```
format = "[...]($style)[ $symbol $branch $git_commit ](fg:moon_bg0 bg:moon_teal)[ ](fg:moon_teal)"
```
Ensure `git_commit` does not conflict with existing `$all_status` or `$ahead_behind`.

**Acceptance:** `starship-rebuild` succeeds. In a git repo, prompt shows branch + 7-char commit hash. Outside a git repo, prompt shows no extra text.

### 2.7 Add `abbr -a dotf 'dot-files'`

**File:** `config/fish/conf.d/30-abbreviations.fish`
**Required change:** Add `abbr -a dotf 'dot-files'` after the other abbreviations.
**Acceptance:** `abbr dotf` expands to `dot-files` on SPACE/ENTER.

---

## Section 3: Maintenance / Refactoring (no behavior change)

### 3.1 Drop `bash -c` entirely from dev-tools.fish __command_version

**File:** `config/fastfetch/dev-tools.fish`, lines 21-35
**Current:** `set -l value (bash -c "$version_command" 2>/dev/null | string collect)`
**Required:** Replace every `bash -c "cmd | sed -E ..."` pattern in the version_command strings with Fish-native `string replace -r` and `string match -r`.
**Acceptance:** No `bash` or `eval` calls remain in dev-tools.fish. Output of `__command_version` for every tool is identical to current output.

### 3.2 Inline `starship-rebuild` wrapper to save subprocess spawn

**File:** `config/fish/functions/starship-rebuild.fish` (delete)
**Files to update:** `config/fish/functions/dot-files.fish` (5 call sites), `config/fish/conf.d/zz-fastfetch.fish` (0 call sites), `config/fish/conf.d/20-starship.fish` (0 call sites)
**Required:** Delete `starship-rebuild.fish`. Replace each `starship-rebuild` call with `fish "$HOME/.config/starship/build.fish"`. Update completions to remove `starship-rebuild` if present.
**Acceptance:** `functions -q starship-rebuild` returns 1 after sourcing the config. All rebuild paths still work.

### 3.3 Extract `__dotfiles_edit_file` caller-visible error paths

**File:** `config/fish/functions/dot-files.fish`, lines 119-145
**Current:** `__dotfiles_edit_file` prints "dot-files: $file_path does not exist" for missing files.
**Required:** Keep the current error path. Each caller already has its own pre-existence check (e.g. `--edit style` checks `$starship_dir/style`). Document that the helper's `-f` guard is a safety net, not the primary check.
**Acceptance:** No behavior change. Just a comment added above `__dotfiles_edit_file`.

---

## Section 4: Documentation Updates (must follow code changes)

### 4.1 Update docs/fish.md to mention new conf.d files

**File:** `docs/fish.md`
**Required additions:**
- Document `conf.d/30-abbreviations.fish` in the startup files table
- Document `conf.d/15-paths.fish` in the startup files table
- Document `functions/nvm.fish` in the functions table
- Document the new `--doctor`, `--status`, `--edit`, `--dev-tools reload` flags

### 4.2 Update docs/customization.md

**File:** `docs/customization.md`
**Required additions:**
- Document `--edit` workflow
- Document `--dev-tools reload`
- Document `--doctor` output
- Document `fish_user_paths` under a new "Persistent PATH" subsection

### 4.3 Update README.md `dot-files` command section

**File:** `README.md`, around line 157-178
**Required additions:** Add `--doctor`, `--status`, `--edit`, and `--dev-tools reload` to the CLI examples.

---

## Section 5: Execution Order

An agent executing this plan must follow this order. Do not reorder.

**Phase A -- Critical fixes (must land before any new features)**
- Task 1.3: Replace bash -c in dev-tools.fish __command_version with Fish-native string replace
- Task 1.2: Make __dotfiles_show_catalog write previews to temp files, not live prefs

**Phase B -- Subprocess overhead reduction**
- Task 3.2: Inline starship-rebuild wrapper (delete the function, inline at call sites)
- Task 3.3: Confirm __dotfiles_edit_file has documentation comment

**Phase C -- New features (in priority order)**
- Task 2.5: Add conf.d/15-paths.fish with fish_user_paths
- Task 2.7: Add abbr -a dotf 'dot-files'
- Task 2.2: Implement dot-files --doctor
- Task 2.4: Implement dot-files --dev-tools reload
- Task 2.3: Implement dot-files --status
- Task 2.6: Add short git commit hash to git.toml

**Phase D -- Documentation sync (after all code changes)**
- Task 4.1: Update docs/fish.md
- Task 4.2: Update docs/customization.md
- Task 4.3: Update README.md

**Phase E -- Validation gate (required before declaring done)**
1. `bash -n install.sh` returns 0
2. `fish --command "source <every .fish file>"` returns 0 for every file
3. `git status --short` returns empty
4. `git log --oneline -5` shows clean, pushable history
5. Every PLANNING.md task has a corresponding git commit with a clear message

---

## Section 6: Out of Scope (do not implement)

- Zsh or Bash config equivalents (Fish-only project)
- Nix / Homebrew packaging for the dotfiles
- Cloud sync of dotfiles (use git, not custom sync)
- GUI configuration tools
- Windows / macOS support (Linux Fish only)
- Starship theme marketplace integration
- Fastfetch module authoring UI
