# Fish Guide

This repository targets **Fish only**. Configuration is split into `conf.d` startup files and autoloaded `functions/`.

## Startup files

```text
config/fish/config.fish
config/fish/conf.d/*.fish
```

Fish loads `conf.d` automatically. File order matters; `zz-*` runs late on purpose.

| File | Purpose |
|------|---------|
| `10-startup-message.fish` | Disables Fish greeting (Fastfetch handles startup) |
| `20-starship.fish` | `starship init fish` |
| `zz-fastfetch.fish` | Fastfetch + Dev Tools (after version managers load) |

## Functions

```text
config/fish/functions/
```

| Function | Description |
|----------|-------------|
| `dot-files` | Manage style, color, welcome name, modules, and Dev Tools preferences |
| `starship-rebuild` | Regenerate `starship.toml` from modules |
| `fastfetch-apply-welcome` | Sync `starship/username` into Fastfetch `config.jsonc` |
| `dotfiles-read-setting` | Read the first non-comment line from a preference file |
| `dotfiles-read-modules` | Read every non-comment line from a preference file |
| `ls` | Icon-aware listing when `eza` / `lsd` are unavailable |

## Fastfetch startup

`zz-fastfetch.fish` runs late so tools on `PATH` (Node, pnpm, etc.) are visible to Dev Tools. It calls `fastfetch-apply-welcome` before Fastfetch so the title reflects `~/.config/starship/username`.
