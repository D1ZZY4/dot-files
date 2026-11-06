# Starship Guide

The Starship setup is modular. Source files live in:

```text
config/starship/modules/
```

The generated file is:

```text
config/starship/starship.toml
```

## Build process

Rebuild the prompt:

```fish
dot-files --edit style      # or --edit color, --edit modules
# or
fish ~/.config/starship/build.fish
```

The build script:

1. Reads the active separator style from `config/starship/style`
2. Replaces `@LEFT@`, `@RIGHT@`, and `@PALETTE@` placeholders in module files (`@PALETTE@` becomes the active color theme name from `config/starship/color`)
3. Concatenates the enabled modules in the order defined by `build.fish`, skipping any disabled in `config/starship/modules.conf`
4. Appends the active palette from `config/starship/colors/` (must be last: TOML keys after `[palettes.*]` belong to that table until the next `[section]`)
5. Writes the generated `starship.toml`

## Module order

Module files are loaded in the explicit order defined by `build.fish`:

```text
core.toml
directory.toml
git.toml
languages.toml
package.toml
file-icons.toml
```

If `modules.conf` is missing or fully commented, the generated config enables
`core directory git languages package` (file-icons stays off), matching the
defaults written by `dot-files --enable-module`.

## Git segment

`git.toml` renders a compact, info-dense git segment:

- `git_branch` and `git_commit` share one teal capsule: branch name plus the
  short commit hash (`commit_hash_length = 7`, always shown, not only when
  detached).
- `git_state` renders a separate yellow capsule only while an operation is in
  progress (`MERGING`, `REBASING`, `CHERRY-PICKING`, …). Nothing is rendered
  otherwise.
- `git_status` renders colored glyphs with counts, one color per status kind:
  staged green `+`, modified yellow `!`, deleted red `✘`, renamed blue `»`,
  untracked sky-blue `?`, stashed purple `󰏗`, conflicted red, typechanged
  yellow `~`. Ahead/behind/diverged are one combined `ahead_behind` variable
  (Starship has no separate `$ahead`/`$behind` format variables), rendered in
  yellow: `⇡2`, `⇣1`, or `⇕⇡2⇣1`.

Because every piece interpolates an empty value when inactive, repos without a
remote or without any changes render cleanly (just branch + hash).

To add a new module, edit `config/starship/build.fish` and insert the filename into the `module_order` list at the correct position.

## Preference files

| File | Purpose |
|------|---------|
| `~/.config/starship/style` | Separator style `1`–`5` |
| `~/.config/starship/color` | Active palette name |
| `~/.config/starship/modules.conf` | Enabled modules (one per line; `#` disables) |
| `~/.config/starship/username` | Fastfetch welcome name (empty = system user) |

Lines starting with `#` are ignored. After editing `style`, `color`, or `modules.conf`, run `dot-files --edit style` (or `--edit color` / `--edit modules`). After `username`, run `fastfetch-apply-welcome`.

## Adding a module

1. Create the source file under `config/starship/modules/`, for example `config/starship/modules/cloud.toml`.
2. Edit `config/starship/build.fish` and insert `cloud` into the `module_order` list at the correct position. To make the module toggleable, also add its name to `__dotfiles_all_modules` in `config/fish/functions/dot-files.fish`.
3. Run `dot-files --edit modules` to regenerate `starship.toml`.

## Separator placeholders

Use placeholders in module format strings:

```toml
format = "[@LEFT@](moon_blue)[ content ](bg:moon_blue fg:moon_bg0)[@RIGHT@ ](fg:moon_blue)"
```

The build script replaces them based on the selected style.

## Right-side time

Time is configured through `right_format`, so it appears on the right side of the prompt when the terminal has enough width.
