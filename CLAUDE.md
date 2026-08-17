# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

Portable terminal environment for **Fish shell only** (no zsh/bash configs — see PLANNING.md "Out of Scope"). Three layers: Fish config, Starship prompt, Fastfetch startup summary with a Dev Tools block. Everything is preference-driven: users edit plain-text files, never generated sources.

## Validation (run after any change)

```sh
bash -n install.sh
# every .fish file must source cleanly:
for f in config/fish config/fastfetch; do
  find $f -name '*.fish' -exec fish --command 'source {}' \; # use: fish -c "source <file>"
done
```

Per PLANNING.md, the validation gate is: `bash -n install.sh` = 0, every `.fish` file sources with `fish --command "source <file>"` = 0, clean `git status`.

## Install flow

`install.sh` (POSIX sh, no bashisms, `set -eu`) installs `config/{fish,starship,fastfetch}` into `$XDG_CONFIG_HOME` (default `~/.config`) as symlinks (default) or copies (`--copy`). Key behaviors:

- `--dry-run` prints actions without executing; env overrides: `DOTFILES_DIR`, `DOTFILES_REPO_URL`, `INSTALL_MODE`, `BACKUP_DIR`, `DRY_RUN`, `DOTFILES_WELCOME_NAME`.
- Replaced files are moved to `~/.dotfiles-backup/<timestamp>/` (preserving relative path) — never delete, always backup.
- After install, runs `fish build.fish` to generate `starship.toml` (Fish required), then symlinks `~/.config/starship.toml` → generated file.
- curl-based install clones to `~/.local/share/dotfiles`; `$0`/tty detection (`[ ! -t 0 ]`) distinguishes pipe from local invocation.
- Works only for interactive Fish; guard all config with `status --is-interactive` in `conf.d/` snippets.

## Architecture

### Starship build pipeline (generated config)

`config/starship/starship.toml` is **generated, not committed**. `build.fish`:

1. Reads `style` (separator 1–5) and `color` (palette name) preference files; env vars `STARSHIP_STYLE_PREVIEW` / `STARSHIP_COLOR_PREVIEW` bypass live prefs (used by preview functions).
2. Maps style number → powerline separator glyphs (left/right pairs).
3. Concatenates enabled `modules/*.toml` in the hardcoded order `core, directory, git, languages, package, file-icons`, substituting tokens: `@LEFT@`, `@RIGHT@`, `@PALETTE@`.
4. Appends `colors/<theme>.toml` **last** — TOML keys after `[palettes.*]` belong to that table until the next `[section]`; palette must close the file.
5. Module enablement from `modules.conf` (one per line; `#` disables; `core` always on).

Adding a module requires: new file in `modules/` + entry in `build.fish` `module_order` + name in `__dotfiles_all_modules` (in `config/fish/functions/dot-files.fish`) to be toggleable. Rebuild via `dot-files --edit modules` or `fish ~/.config/starship/build.fish`.

### Preference files

Everyday options are plain-text files, `#` = comment, first non-comment line is the value (`dotfiles-read-setting`). Under `~/.config/starship/`:

| File | Purpose |
|------|---------|
| `style` | separator 1–5 |
| `color` | palette name (`moonlight` \| `catppuccin-macchiato` \| `catppuccin-mocha`) |
| `username` | Fastfetch welcome name; empty = system username |
| `modules.conf` | enabled Starship modules |
| `dev-tools.toml` | Dev Tools tool visibility (TOML sections: runtimes, packages, python, system_tools, infrastructure) |
| `ls-style`, `ll-style`, `ls-group` | eza output styles |

### Fish load order and conventions

- `config.fish` is a minimal entry point; startup fragments live in `conf.d/` (numbered: `10-startup-message`, `15-paths`, `20-starship`, `30-abbreviations`, `zz-fastfetch`). Fish loads them alphabetically — `zz-` loads last by design (fastfetch needs version managers initialized first).
- Starship init is **deferred to first prompt** via `__starship_init --on-event fish_prompt` guard (avoids spawning Rust binary on every shell start). Uses `command starship` to bypass function shadowing.
- Fastfetch runs **backgrounded** (`begin ... end &`) in `zz-fastfetch.fish` so it doesn't slow shell startup.
- PATH: `conf.d/15-paths.fish` initializes universal `fish_user_paths` — never hardcode paths in config, tool dirs are added via `set -U`.
- **Subdirectory helper pattern** (Fish autoloads only direct children of `functions/`): each function dir sources sibling `*.fish` helpers explicitly at load time. Same pattern in `functions/dot-files/` (18 `__dotfiles_*` helpers), `functions/ls/` (icon helpers), and `config/fastfetch/dev-tools/` (`__dt_*` helpers).
- `functions/dot-files.fish` is the main `dot-files` CLI dispatcher (switch on `$argv[1]`).

### dot-files command

`dot-files` (Fish function + completions) manages everything: `--style`, `--color`, `--username`, `--enable-module`/`--disable-module`/`--list-modules`, `--dev-tools init|toggle|reload`, `--edit style|color|modules|username|dev-tools`, `--ls-style`, `--ll-style`, `--ls-group`, `--doctor`, `--status`. Post-change rebuild: `fish "$build_fish"` + preview block. `--dev-tools reload` sources dev-tools.fish with `__dt_force_no_auto_render` set and calls `__dt_reload` (mtime-cached) — no `exec fish` needed.

### Dev Tools block (fastfetch)

`config/fastfetch/dev-tools.fish` detects installed tools on PATH and renders version lines per section. Conventions:
- No `bash -c` / `eval` anywhere (security invariant, per PLANNING.md) — Fish-native `string replace -r` only.
- `__dt_enabled <tool>` consults `dev-tools.toml`; uninstalled tools omitted regardless.
- Python discovered from executables named `python3.x` via `__dt_python_lines`/`__dt_collect_python_binaries`.
- Adding a tool: `__tool_line` entry in the matching section + key in `dev-tools.toml` init template + `__dotfiles_devtools_list`.

### ls style previews

`config/fish/functions/dot-files/ls-helpers.fish` provides the live preview pipeline for
`ls-style` (1–6) and `ll-style` (1–6). The key insight: Fish command substitution
`(echo "--git --header")` yields a single array element, not separate arguments, so the
preview helpers call `eza` directly inside `switch`/`case` blocks rather than echo-ing a
command string for later eval.

- `__dotfiles_ls_preview <style> [dir]` — runs eza with the matching flags; `--color=always`
  preserves ANSI colors through the `sed` pipe in the catalog renderer.
- `__dotfiles_ll_preview <style> [dir]` — same for long-form listings.
- `__dotfiles_ls_flags` / `__dotfiles_ll_flags` — return only the flags for a given style
  number, used by the no-eza text preview path.
- `__dotfiles_ls_style_preview` / `__dotfiles_ll_style_preview` — text description lines
  used when eza is not installed.
- `__dotfiles_ls_group` — returns `--group-directories-first` when `ls-group` is `on`,
  nothing otherwise.
- `__dotfiles_ls_cmd` / `__dotfiles_ll_cmd` — echo the full eza command string for the
  active style, consumed by the `ls`/`ll` abbreviations.

`__dotfiles_show_catalog` renders live previews: if eza is on PATH, it pipes each
`__dotfiles_*_preview` through `sed 's/^/    /'` for indented colored output; otherwise it
falls back to the text description.

### ls fallback

`functions/ls.fish` wraps `ls`: eza → lsd → bundled icon-aware fallback (GNU-flags parser, `__ls_*` helpers). `dot-files --ls-style/--ll-style/--ls-group` only affect the eza-based `ls`/`ll` abbreviations, not the fallback.

### nvm wrapper

`functions/nvm.fish` lazy-loads bash nvm via `bash -c` with `NVM_DIR` passed as positional arg (prevents quote breakout); marker flag `__nvm_loaded` instead of `type -q nvm` (function shadows itself).

## Docs and planning

- `PLANNING.md` — master task list with exact acceptance criteria; keep in sync when adding work. Section 6 lists out-of-scope items (no zsh/bash, no nix/homebrew packaging, no GUI tools, no macOS support).
- `docs/` — installation, customization, starship, fish, troubleshooting guides. Update them when behavior changes (README + docs are checked in the "what the installer does" / repo-layout expectations).
- Memory notes in `.claude/memory/` record past audits and decisions.

## Gotchas

- `fastfetch-apply-welcome` edits `config.jsonc` with `string replace -r` via mktemp; it first greps for the `"format": "Welcome, ...!"` pattern because `string replace -r` always exits 0.
- `__dotfiles_regex_escape` exists because `sed` module/tool names must be escaped before `s/^name$/.../` substitution.
- Starfield directory icons use `directory.substitutions` (string replace, not segment matching) — avoid generic keys like `test` or `cache` that could match unrelated paths.
- Runtime paths resolve through `$HOME`/`$XDG_CONFIG_HOME` — no hardcoded usernames or machine paths (README's design constraint).
