# Fish Guide

This repository targets **Fish only**. Configuration is split into `conf.d` startup files and autoloaded `functions/`.

## Requirements

- [Fish shell](https://fishshell.com/)
- [Starship](https://starship.rs/)
- [Fastfetch](https://github.com/fastfetch-cli/fastfetch)
- [eza](https://github.com/eza-community/eza) — modern `ls` replacement (**v0.23.5+** recommended) — required for `ls`/`ll` live previews and enhanced directory listings

## Startup files

```text
config/fish/config.fish
config/fish/conf.d/*.fish
```

Fish loads `conf.d` automatically. File order matters; `zz-*` runs late on purpose.

| File | Purpose |
|------|---------|
| `10-startup-message.fish` | Disables Fish greeting (Fastfetch handles startup) |
| `15-paths.fish` | Persistent `fish_user_paths` for tool-managed PATH entries |
| `20-starship.fish` | `starship init fish` |
| `30-abbreviations.fish` | **Loader** — sources all files from `abbreviations/` |
| `zz-fastfetch.fish` | Fastfetch + Dev Tools (after version managers load) |

## Abbreviations (modular)

All abbreviations live in `conf.d/abbreviations/` as separate files per tool category.
The loader `30-abbreviations.fish` sources them all automatically.

```text
config/fish/conf.d/abbreviations/
├── ls.fish                   # ls/ll/l/la/lt/lta/ld/lf/l./lx/lh/li/lo/lg/lgr/lgs/loc/lc/lk
├── git.fish                  # g/gst/glog/gd/ga/gc/gp/gpl/gstash/gsw/…
├── docker.fish               # d/dco/dps/dcu/dcd
├── kubectl.fish              # k/kx/kl/kctx/kns
├── gh.fish                   # ghg/ghpr/ghrv/ghi
├── terraform.fish            # tf/tfi/tfp/tfa
├── tool-replacements.fish    # cat→bat, find→fd, grep→rg, du→dust, ps→procs, cd→z
└── general.fish              # dotf/../.../...../...../c/cl/h/j
```

To add a new abbreviation, create a new `abbreviations/<name>.fish` file.

## Abbreviation Reference

All abbreviations expand on SPACE or ENTER in interactive sessions.

### ls — eza / lsd

When **eza** is installed, activated via style system:

| Abbrev | Default command | Description |
|--------|----------------|-------------|
| `ls` | *style-dependent* | Grid (\#1), one-per-line (\#2), tree (\#3), git+header (\#4), git (\#5), loc (\#6) |
| `ll` | *style-dependent* | Default (\#1), header (\#2), git (\#3), header+group+iso (\#4), inode (\#5), color-scale (\#6) |
| `l` | `eza -1 --icons` | One entry per line |
| `la` | `eza -la --icons` | All files (including hidden) long format |
| `ld` | `eza -D --icons` | Directories only |
| `lf` | `eza -f --icons` | Files only (show symlinks) |
| `l.` | `eza -la -I='[!.]*' --icons` | Hidden files only |
| `lx` | `eza -x --icons` | Grid sorted horizontally (across, then down) |
| `lt` | `eza --tree --level=2 --icons` | Tree view, 2 levels |
| `lta` | `eza --tree --level=3 --icons -a` | Tree view, 3 levels, show hidden |
| `lh` | `eza -la --header --icons` | Long with column headers |
| `li` | `eza -la --inode --icons` | Show inode numbers |
| `lo` | `eza -la --octal-permissions --icons` | Octal permissions |
| `lg` | `eza -la --git --icons` | Git status per file |
| `lgr` | `eza --git-repos --icons` | Git repository summary (branch, status) |
| `lgs` | `eza -la --git --smart-group --time-style=iso` | Git + owner group + ISO timestamps |
| `loc` | `eza --code --icons` | Lines-of-code summary by language |
| `lc` | `eza --color-scale=all --icons` | Age/size highlighted with color gradient |
| `lk` | `eza --hyperlink=always --icons` | Clickable terminal hyperlinks |

### git

| Abbrev | Expands to |
|--------|-----------|
| `g` | `git` |
| `gst` | `git status -sb` |
| `glog` | `git log --oneline --graph --decorate --all` |
| `gd` | `git diff` |
| `gds` | `git diff --staged` |
| `ga` | `git add` |
| `gc` | `git commit` |
| `gca` | `git commit --amend --no-edit` |
| `gco` | `git checkout` |
| `gcb` | `git checkout -b` |
| `gp` | `git push` |
| `gpl` | `git pull --rebase` |
| `gstash` | `git stash` |
| `gsw` | `git switch` |

### docker

| Abbrev | Expands to |
|--------|-----------|
| `d` | `docker` |
| `dco` | `docker compose` |
| `dps` | `docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"` |
| `dcu` | `docker compose up -d` |
| `dcd` | `docker compose down` |

### kubectl

| Abbrev | Expands to |
|--------|-----------|
| `k` | `kubectl` |
| `kx` | `kubectl exec -it` |
| `kl` | `kubectl logs -f` |
| `kctx` | `kubectl config use-context` |
| `kns` | `kubectl config set-context --current --namespace` |

### GitHub CLI

| Abbrev | Expands to |
|--------|-----------|
| `ghg` | `gh browse` |
| `ghpr` | `gh pr create --fill` |
| `ghrv` | `gh repo view --web` |
| `ghi` | `gh issue list` |

### Terraform

| Abbrev | Expands to |
|--------|-----------|
| `tf` | `terraform` |
| `tfi` | `terraform init` |
| `tfp` | `terraform plan` |
| `tfa` | `terraform apply` |

### Tool replacements

| Abbrev | Expands to | Requires |
|--------|-----------|----------|
| `cat` | `bat` | bat |
| `find` | `fd` | fd |
| `grep` | `rg` | ripgrep |
| `du` | `dust` | dust |
| `ps` | `procs` | procs |
| `cd` | `z` | zoxide |

### General

| Abbrev | Expands to |
|--------|-----------|
| `dotf` | `dot-files` |
| `..` | `cd ..` |
| `...` | `cd ../..` |
| `....` | `cd ../../..` |
| `.....` | `cd ../../../..` |
| `c` | `clear` |
| `cl` | `clear` |
| `h` | `history` |
| `j` | `jobs` |

## Functions

```text
config/fish/functions/
```

| Function | Description |
|----------|-------------|
| `dot-files` | Manage style, color, welcome name, modules, Dev Tools, diagnostics, and ls/ll styles |
| `fastfetch-apply-welcome` | Sync `starship/username` into Fastfetch `config.jsonc` |
| `dotfiles-read-setting` | Read the first non-comment line from a preference file |
| `dotfiles-read-modules` | Read every non-comment line from a preference file |
| `ls` | Icon-aware listing when `eza` / `lsd` are unavailable |
| `nvm` | Node Version Manager helper |

### ls fallback (when eza/lsd not installed)

The `ls` function in `functions/ls.fish` delegates to `eza` / `lsd` if one of them is available.
If neither is installed, it runs an icon-aware fallback using `functions/ls/*.fish` helpers:

| Helper | Purpose |
|--------|---------|
| `__ls_entries` | List directory entries (handles -a/-A) |
| `__ls_full_path` | Resolve relative path to absolute |
| `__ls_icon` | Nerd Font icon mapping (~90 file types and directory names) |
| `__ls_column_icons` | Grid/column display (supports -1 for one-per-line) |
| `__ls_long_icons` | Long-format display with stat, symlink targets |

The fallback parses combined flags (`-la`, `-lA`, `-laF`, `-1`, `-R`, `-d`, `-F`, `-r`, `-t`, `-S`) and passes unknown flags to `command ls`.

## Fastfetch startup

`zz-fastfetch.fish` runs late so tools on `PATH` (Node, pnpm, etc.) are visible to Dev Tools. It calls `fastfetch-apply-welcome` before Fastfetch so the title reflects `~/.config/starship/username`.

## dot-files command reference

Run `dot-files` with no arguments to see active settings, live prompt style/color previews, **and ls/ll command previews**.

```fish
dot-files                              # usage, active settings, previews
dot-files --style 5                    # set prompt separator style 1-5
dot-files --color moonlight            # set color palette
dot-files --username "Alex"            # set Fastfetch welcome name
dot-files --username reset             # back to system username
dot-files --edit style|color|modules|username|dev-tools  # edit preference file

# Modules
dot-files --list-modules
dot-files --enable-module git
dot-files --disable-module file-icons

# Dev Tools
dot-files --dev-tools init
dot-files --dev-tools toggle docker
dot-files --dev-tools reload           # re-render Dev Tools without restart

# Diagnostics
dot-files --doctor                     # run diagnostics
dot-files --status                     # show dotfiles git status

# ls/ll style system
dot-files --ls-style 1|2|3|4|5|6      # set eza ls output style
dot-files --ll-style 1|2|3|4|5|6      # set eza ll output style
dot-files --ls-group on|off            # toggle group-directories-first
```

### ls style reference

| Style | Command | Description |
|-------|---------|-------------|
| 1 (grid) | `eza --icons --group-dirs-first` | Default grid layout |
| 2 (one-per-line) | `eza -1 --icons` | One file per line |
| 3 (tree) | `eza -T -L=1 --icons` | Single-level tree |
| 4 (git+header) | `eza --git --header --icons` | Git status + column header |
| 5 (git) | `eza --git --icons` | Git status |
| 6 (loc) | `eza --code --icons` | Lines-of-code summary |

### ll style reference

| Style | Command | Description |
|-------|---------|-------------|
| 1 (default) | `eza -la --icons` | Standard long format |
| 2 (header) | `eza -la --header --icons` | Long with column headers |
| 3 (git) | `eza -la --git --icons` | Long + git status |
| 4 (header+group+iso) | `eza -la --header --group --time-style=iso` | Headers, group, ISO dates |
| 5 (inode) | `eza -la --header --git --inode` | Inode + git + headers |
| 6 (color-scale) | `eza -la --git --color-scale=all` | Git + age/size gradient |

### --edit workflow

Open the active preference file for the chosen target and apply any rebuild after
the editor closes:

- `style` / `color` / `modules` — rebuilds the Starship prompt then shows a preview
- `username` — runs `fastfetch-apply-welcome`
- `dev-tools` — prints a reminder that changes apply on next startup, or run `dot-files --dev-tools reload` to apply now

## Persistent PATH with `fish_user_paths`

`conf.d/15-paths.fish` creates the universal `fish_user_paths` variable if it
doesn't exist. Tools like `fnm`, `mise`, `cargo`, and `go` write their `bin/`
directories there; Fish prepends them to `PATH` on every shell start and
deduplicates automatically.

```fish
# Example: add cargo to the persistent PATH
set -U fish_user_paths ~/.cargo/bin $fish_user_paths
```

## Dev Tools block

The Dev Tools block is generated by:

```text
~/.config/fastfetch/dev-tools.fish
```

It lists tools found on `PATH` (Node.js, package managers, Python, Git, Docker, and others). Missing tools are omitted.

To add a tool, edit `dev-tools.fish`: add an `__tool_line` entry in the appropriate section.

Python versions are discovered from executables named `python3.x` on `PATH`.

### Toggling tools

Create the visibility config, then toggle individual tools:

```fish
dot-files --dev-tools init
dot-files --dev-tools toggle docker
```

The config lives in `~/.config/starship/dev-tools.toml`. Set any `<tool> = false` to hide it. Tools that are not installed are omitted regardless.

### Hot reload

`dot-files --dev-tools reload` re-reads `dev-tools.toml` and re-renders the Dev
Tools block in the current terminal without restarting the shell.

## nvm wrapper

`functions/nvm.fish` lazy-loads Node Version Manager on first call. Because
nvm is a bash-only script, the wrapper delegates to `bash -lc` when nvm has
not already been loaded into the session. The `$NVM_DIR` environment variable
is respected if set.