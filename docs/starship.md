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
3. Concatenates modules in lexical order
4. Appends the active palette from `config/starship/colors/` (must be last: TOML keys after `[palettes.*]` belong to that table until the next `[section]`)
5. Writes the generated `starship.toml`

## Module order

Module files are sorted by filename:

```text
00-core.toml
10-directory.toml
20-git.toml
30-languages.toml
40-package.toml
```

Use numeric prefixes to control load order.

## Preference files

| File | Purpose |
|------|---------|
| `~/.config/starship/style` | Separator style `1`–`5` |
| `~/.config/starship/color` | Active palette name |
| `~/.config/starship/username` | Fastfetch welcome name (empty = system user) |

Lines starting with `#` are ignored. After editing `style` or `color`, run `starship-rebuild`. After `username`, run `fastfetch-apply-welcome`.

## Adding a module

Create a new file under `config/starship/modules/`, for example:

```text
60-cloud.toml
```

Then run:

```fish
starship-rebuild
```

## Separator placeholders

Use placeholders in module format strings:

```toml
format = "[@LEFT@](moon_blue)[ content ](bg:moon_blue fg:moon_bg0)[@RIGHT@ ](fg:moon_blue)"
```

The build script replaces them based on the selected style.

## Right-side time

Time is configured through `right_format`, so it appears on the right side of the prompt when the terminal has enough width.
