# PLANNING.md

> Master task list for the dot-files project.
> Every item below is written to be executed by an AI agent without ambiguity.
> Each task has: exact file paths, current state, required change, acceptance criteria.
> Do not skip tasks. Do not reorder without updating this document.

---

## Section 0: Project State Lock

**Base commit:** `b863b39` (HEAD of main, already pushed to origin/main)
**Branch:** main
**Working tree:** clean (no uncommitted changes)

Recent history:
- `b863b39` refactor(starship): rename moon_* palette tokens to color_* across all palettes and modules
- `4582328` docs(claude): add ls style preview architecture and helper reference
- `fdab523` docs(readme): document ls/ll live style previews in catalog
- `4c75b4f` feat(fish): add __dotfiles_ls_preview and __dotfiles_ll_preview helpers
- `95e8fff` refactor(fish): delegate ls/ll previews to helper functions

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
- **1.6 Prompt preview cache reverted** — Broken due to Fish assoc array key limits (commit `0259133`).
- **1.7 Starship binary invoked directly** — Uses `command starship` to bypass function shadowing (commit `5f22c71`).
- **1.8 agents/ directory removed** — Stale directory cleaned up (commit `6af29a2`).
- **1.9 Interactive guard on abbreviation loader** — Prevents loading in non-interactive sessions (commit `8f038cc`).
- **1.10 Grep glob expansion fixed in dev-tools** — Prevents invalid tool detection (commit `741c678`).
- **1.11 Username handler simplified** — Clarified paths guard and system/custom username display (commit `0d87b92`).
- **1.12 Starship rebuild cache added** — mtime-cached rebuild and prompt preview renders (commit `dbddcf7`).
- **1.13 Live eza previews for ls/ll styles** — `__dotfiles_ls_preview`/`__dotfiles_ll_preview` helpers with `--color=always`; `__dotfiles_show_catalog` renders live eza output or falls back to text descriptions (commits `7d10b2b`, `95e8fff`, `4c75b4f`).
- **1.14 ls/ll previews documented** — README and CLAUDE.md updated with preview architecture (commits `fdab523`, `4582328`).
- **1.15 Palette tokens renamed** — `moon_*` → `color_*` across all 3 palettes and 4 modules (commit `b863b39`).
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

## Section 2: Completed

- **2.1 Remove unused palette colors** — Done in `b863b39`. Also renamed `moon_*` tokens to `color_*` across all 3 palettes and 4 modules. All palette files now contain exactly the colors referenced by `modules/*.toml`.
- **2.2 Update docs with audit-driven improvements** — Already covered by prior commits: "Starry" typo fixed, `dev-tools.toml` documented in `docs/installation.md` and README pref table, README repo-layout tree expanded, CLI flags (`--doctor`, `--status`, `--ls-style`, `--ll-style`, `--ls-group`) documented. No remaining doc gaps identified.

---

## Section 5: Execution Order

**Phase F — Polish (complete)**
- Task 2.1: Remove unused palette colors — done in `b863b39`
- Task 2.2: Documentation touch-ups — covered by prior commits

**Phase E — Validation gate (run before declaring a release done)**
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
