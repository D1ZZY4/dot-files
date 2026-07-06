# Installation Guide

**Fish shell only.** Install Fish, Starship, Fastfetch, and Git before running the installer.

## Prerequisites

- `fish` — required (login shell)
- `starship`
- `fastfetch`
- `git` — required for curl-based install
- A Nerd Font — [FiraCode Nerd Font](https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/FiraCode.zip) recommended (required for prompt and Fastfetch glyphs)

Optional tools listed in the Dev Tools block: Node.js, npm, pnpm, Python, Go, Rust, Java, Git, Docker, and others.

## Quick install (curl)

The commands below install from `D1ZZY4/dot-files`. Forking? Replace `D1ZZY4/dot-files` with your own `<user>/<repo>` and set `DOTFILES_REPO_URL` in `install.sh` before publishing your own one-liner.

```sh
curl -fsSL https://raw.githubusercontent.com/D1ZZY4/dot-files/main/install.sh | sh
```

Custom welcome title during install:

```sh
curl -fsSL https://raw.githubusercontent.com/D1ZZY4/dot-files/main/install.sh | sh -s -- --welcome "Alex"
```

Or:

```sh
DOTFILES_WELCOME_NAME="Alex" \
  curl -fsSL https://raw.githubusercontent.com/D1ZZY4/dot-files/main/install.sh | sh
```

## Clone-based installation

```sh
git clone https://github.com/D1ZZY4/dot-files.git ~/.local/share/dotfiles
cd ~/.local/share/dotfiles
./install.sh
```

## Installer options

```sh
./install.sh              # symlink into ~/.config (default)
./install.sh --copy       # copy files instead of symlinks
./install.sh --dry-run    # preview actions
./install.sh --welcome "Alex"
```

## Preference files

After install, edit these directly or use `dot-files`:

```text
~/.config/starship/style         # 1-5
~/.config/starship/color         # moonlight | catppuccin-macchiato | catppuccin-mocha
~/.config/starship/username      # empty = system user; one line = custom name
~/.config/starship/modules.conf  # enabled modules (created on first toggle)
```

Empty `username` (comments only) keeps Fastfetch on `Welcome, {user-name}!`.

## Backup behavior

Replaced files move to:

```text
~/.dotfiles-backup/<timestamp>/
```

## Generated Starship config

Source modules:

```text
~/.config/starship/modules/
```

Generated output:

```text
~/.config/starship/starship.toml
~/.config/starship.toml -> .../starship/starship.toml
```

Regenerate after module or preference changes:

```fish
starship-rebuild
```
