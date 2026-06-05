# Installation Guide

**Fish shell only.** Install Fish, Starship, Fastfetch, and Git before running the installer.

## Prerequisites

- `fish` — required (login shell)
- `starship`
- `fastfetch`
- `git` — required for curl-based install

Optional tools listed in the Dev Tools block: Node.js, npm, pnpm, Python, Go, Rust, Java, Git, Docker, and others.

## Quick install (curl)

Replace `<user>/<repo>` with your repository. Set `DOTFILES_REPO_URL` in `install.sh` before publishing a one-liner without env vars.

```sh
curl -fsSL https://raw.githubusercontent.com/<user>/<repo>/main/install.sh | sh
```

Custom welcome title during install:

```sh
curl -fsSL https://raw.githubusercontent.com/<user>/<repo>/main/install.sh | sh -s -- --welcome "Alex"
```

Or:

```sh
DOTFILES_WELCOME_NAME="Alex" \
  curl -fsSL https://raw.githubusercontent.com/<user>/<repo>/main/install.sh | sh
```

## Clone-based installation

```sh
git clone https://github.com/<user>/<repo>.git ~/.local/share/dotfiles
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

After install, edit these directly or use `starship-dotfiles`:

```text
~/.config/starship/style       # 1-5
~/.config/starship/color       # moonlight | catppuccin-macchiato
~/.config/starship/username    # empty = system user; one line = custom name
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
