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

## Section 1: Completed (already resolved in git history)

The following items are already resolved. Do not redo them.

- **1.1 starship-rebuild wrapper** — Deleted `starship-rebuild.fish` (commit `75101db`). All call sites inlined with `fish "$build_fish"`.
- **1.2 Preview loop isolates from live prefs** — `build.fish` reads `STARSHIP_STYLE_PREVIEW`/`STARSHIP_COLOR_PREVIEW` env overrides (commit `c076b59`).
- **1.3 dev-tools.fish no longer uses bash -c** — All tool checks use Fish-native `string replace -r` (commit `984c93d`).
- **1.4 `__command_version` injection documented** — Security invariant noted in dev-tools.fish (commit `bad2042`).
- **1.5 `__dotfiles_edit_file` caller-visible error paths** — Comment added above helper, guards documented (commit `d8156d9`).
- **2.1 `dot-files --edit` for all preference files** — All five targets implemented with post-edit rebuild `__dotfiles_edit_file` + completions.
- **2.2 `dot-files --doctor`** — Full diagnostic command implemented in `dot-files.fish` with 8 checks.
- **2.3 `dot-files --status`** — Git status reporting implemented with ahead/behind tracking.
- **2.4 `dot-files --dev-tools reload`** — `__dt_reload` function with mtime caching implemented.
- **2.5 `fish_user_paths`** — `conf.d/15-paths.fish` created with universal variable init.
- **2.6 Git commit hash** — `$git_commit` added to `git.toml` format string for 7-char hash display.
- **2.7 `dotf` abbreviation** — `abbr -a dotf 'dot-files'` added to `30-abbreviations.fish`.
- **3.1 Drop `bash -c` from dev-tools** — No `bash -c` or `eval` calls remain in dev-tools.fish.
- **3.2 Inline `starship-rebuild`** — Wrapper deleted, all call sites use `fish build.fish` directly.
- **3.3 `__dotfiles_edit_file` error paths** — Safety-net guard documented in comment above function.
- **4.1 docs/fish.md updates** — All new conf.d files, functions, and CLI flags documented.
- **4.2 docs/customization.md updates** — `--edit`, `--dev-tools reload`, `--doctor`, `fish_user_paths` documented.
- **4.3 README.md updates** — CLI examples include `--doctor`, `--status`, `--edit`, `--dev-tools reload`.

## Section 2: Remaining Tasks (implement in priority order)

### 2.1 Remove unused palette colors

**Files:** `config/starship/colors/moonlight.toml`, `catppuccin-macchiato.toml`, `catppuccin-mocha.toml`
**Change:** Remove `moon_bg1`, `moon_cyan`, `moon_indigo`, `moon_pink` from all three palette files (unreferenced in any module).
**Acceptance:** Each palette file contains exactly the colors used by modules/*.toml.

### 2.2 Update docs with audit-driven improvements

**File:** `docs/customization.md` (fix "Starry" typo), `docs/installation.md` (add dev-tools.toml to pref table), `docs/fish.md` (verify all flags documented), `README.md` (expand repo-layout tree).

---

## Section 5: Execution Order

**Phase F — Polish (current batch)**
- Task 2.1: Remove unused palette colors
- Task 2.2: Documentation touch-ups

**Phase E — Validation gate (required before declaring done)**
1. `bash -n install.sh` returns 0
2. `fish --command "source <every .fish file>"` returns 0 for every file under config/fish/ and config/fastfetch/
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
