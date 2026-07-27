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

Run:

```fish
starship-rebuild
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

To add a new module, edit `config/starship/build.fish` and insert the filename into the `module_order` list at the correct position.

## Preference files

| File | Purpose |
|------|---------|
| `~/.config/starship/style` | Separator style `1`–`5` |
| `~/.config/starship/color` | Active palette name |
| `~/.config/starship/modules.conf` | Enabled modules (one per line; `#` disables) |
| `~/.config/starship/username` | Fastfetch welcome name (empty = system user) |

Lines starting with `#` are ignored. After editing `style`, `color`, or `modules.conf`, run `starship-rebuild`. After `username`, run `fastfetch-apply-welcome`.

## Adding a module

1. Create the source file under `config/starship/modules/`, for example `config/starship/modules/cloud.toml`.
2. Edit `config/starship/build.fish` and insert `cloud` into the `module_order` list at the correct position. To make the module toggleable, also add its name to `__dotfiles_all_modules` in `config/fish/functions/dot-files.fish`.
3. Run `starship-rebuild`.

## Separator placeholders

Use placeholders in module format strings:

```toml
format = "[@LEFT@](moon_blue)[ content ](bg:moon_blue fg:moon_bg0)[@RIGHT@ ](fg:moon_blue)"
```

The build script replaces them based on the selected style.

## Right-side time

Time is configured through `right_format`, so it appears on the right side of the prompt when the terminal has enough width.
