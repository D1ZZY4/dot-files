# Dotfiles

A portable, modular terminal configuration for **Fish**, Starship, and Fastfetch.

> **Fish shell only.** This repository is written for the [Fish shell](https://fishshell.com/) and is not compatible with Zsh, Bash, PowerShell, Nushell, or other shells. Fish functions, `conf.d` snippets, and install-time steps (such as Starship config generation) assume Fish. Use Fish as your login shell before installing.

The setup focuses on a clean developer experience:

- Modular Fish configuration under `conf.d/` and `functions/`
- Starship prompt with switchable separator styles
- Modular Starship color themes under `config/starship/colors/`
- Fastfetch startup summary followed by a dedicated Dev Tools block
- Icon-aware `ls` fallback for systems without `eza` or `lsd`
- Safe installer with backup, symlink, copy, dry-run, and curl-based install

## Shell support

| Shell | Supported |
|-------|-----------|
| Fish | Yes - required |
| Zsh | No |
| Bash | No |
| Other shells | No |

Starship and Fastfetch configs are shell-agnostic once installed, but this repo only ships Fish integration (`starship init fish`, `starship-dotfiles`, `starship-rebuild`, and related helpers).

## Preview

Fastfetch runs first:

```text
Welcome, user!
------------
OS        Fedora Linux
Shell     fish
Terminal  Ptyxis
...
```

Then the Dev Tools block is printed separately. Tools that are not installed are omitted:

```text
────────────────────────────────────────────
Dev Tools
────────────────────────────────────────────
Runtimes
   nodejs  v26.3.0
Package managers
   npm  v11.16.0
   pnpm  v11.5.1
Python
   python
    ├─ 3.11 - v3.11.15
    ├─ 3.12 - v3.12.13
    ├─ 3.13 - v3.13.13
    └─ 3.14 - v3.14.5
```

Starship prompt example with the default style 5:

```text
 󰣛 user   ~ 

```

## Requirements

Required:

- **Fish shell** (login or interactive shell you use daily)
- Starship
- Fastfetch
- Git (required for curl-based install; clone-based install also uses Git)
- Nerd Font compatible terminal font, such as FiraCode Nerd Font

Recommended tools detected by Dev Tools:

- Node.js, npm, pnpm, yarn, bun, deno
- Python interpreters exposed as `python3.x` commands
- Go, Rust, Java
- Git, GitHub CLI, Docker, Docker Compose, kubectl
- `eza` or `lsd` for richer listing output. If neither exists, the included Fish `ls` fallback is used.

## Installation

Replace `<user>/<repo>` and branch name (`main`) with your fork before running the commands below. For curl installs, also set the default URL in `install.sh` (`DOTFILES_REPO_URL` near the top) so the one-liner matches your repository.

### Quick install (curl)

Downloads `install.sh`, shallow-clones the repository to `~/.local/share/dotfiles`, installs configs, and generates Starship settings with Fish.

```sh
curl -fsSL https://raw.githubusercontent.com/<user>/<repo>/main/install.sh | sh
```

Copy files instead of symlinking:

```sh
curl -fsSL https://raw.githubusercontent.com/<user>/<repo>/main/install.sh | sh -s -- --copy
```

Preview without applying changes:

```sh
curl -fsSL https://raw.githubusercontent.com/<user>/<repo>/main/install.sh | sh -s -- --dry-run
```

Install from a different fork or branch:

```sh
DOTFILES_REPO_URL="https://github.com/<user>/<repo>.git" \
  curl -fsSL https://raw.githubusercontent.com/<user>/<repo>/main/install.sh | sh
```

After install, restart Fish or run:

```fish
exec fish
```

### Clone and install

Use this workflow if you want a local checkout to edit before or after installing.

```sh
git clone https://github.com/<user>/<repo>.git ~/.local/share/dotfiles
cd ~/.local/share/dotfiles
./install.sh
```

### Copy instead of symlink

Use copy mode if you want installed files to be independent from the repository checkout.

```sh
./install.sh --copy
```

### Dry run

Preview changes before applying them.

```sh
./install.sh --dry-run
```

## Preference files

Everyday options live in plain-text files (lines starting with `#` are comments):

| File | Purpose |
|------|---------|
| `~/.config/starship/style` | Prompt separator `1`–`5` |
| `~/.config/starship/color` | Palette: `moonlight` or `catppuccin-macchiato` |
| `~/.config/starship/username` | Fastfetch welcome name |

Leave `username` empty (comments only) to use your **system username** (`Welcome, {user-name}!`). Add one line (for example `Alex`) for a custom title, then run `fastfetch-apply-welcome` or open a new Fish session.

## Runtime customization

Use the Fish helper or edit the files above directly:

```fish
starship-dotfiles                  # show paths and options
starship-dotfiles --style 5
starship-dotfiles --color moonlight
starship-dotfiles --color catppuccin-macchiato
starship-dotfiles --username "Your Name"
starship-dotfiles --username reset # back to system username
```

Install with a custom welcome title:

```sh
./install.sh --welcome "Your Name"
```

## Starship styles

Style 5 is the default.

```text
style 1 : █ ... █
style 2 : ░▒▓ ... ▓▒░
style 3 :  ... 
style 4 :  ... 
style 5 :  ... 
```

## Color themes

Color themes live in:

```text
config/starship/colors/
```

Currently included:

```text
moonlight
catppuccin-macchiato
```

Each theme has its own Starship palette (`palettes.moonlight`, `palettes.catppuccin-macchiato`). The active theme is selected via `starship-dotfiles --color` and written to `~/.config/starship/color` before rebuild.

## What the installer does

The installer:

1. Installs files from `config/fish` into `~/.config/fish`
2. Installs files from `config/starship` into `~/.config/starship`
3. Installs files from `config/fastfetch` into `~/.config/fastfetch`
4. Generates `~/.config/starship/starship.toml` (requires Fish)
5. Links `~/.config/starship.toml` to the generated Starship config
6. Backs up replaced files under `~/.dotfiles-backup/<timestamp>`

## Generated files

`config/starship/starship.toml` is intentionally not committed. It is generated from modular source files by:

```fish
starship-rebuild
```

or:

```fish
fish ~/.config/starship/build.fish
```

## Repository layout

```text
.
├── config/
│   ├── fastfetch/
│   ├── fish/
│   └── starship/
│       ├── colors/
│       ├── modules/
│       ├── style      # preference: separator 1-5
│       ├── color      # preference: palette name
│       └── username   # preference: Fastfetch welcome name
├── docs/
├── install.sh
├── LICENSE
└── README.md
```

## Documentation

- [Installation Guide](docs/installation.md)
- [Customization Guide](docs/customization.md)
- [Starship Guide](docs/starship.md)
- [Fish Guide](docs/fish.md)
- [Troubleshooting](docs/troubleshooting.md)

## Notes

This repository intentionally avoids hardcoded usernames and machine-specific home paths. Runtime paths are resolved through `$HOME`, `$XDG_CONFIG_HOME`, and command discovery where practical.
