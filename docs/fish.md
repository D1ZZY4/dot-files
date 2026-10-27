# Fish Guide

This repository targets **Fish only**. Configuration is split into `conf.d` startup files and autoloaded `functions/`.

## Requirements

- [Fish shell](https://fishshell.com/)
- [Starship](https://starship.rs/)
- [Fastfetch](https://github.com/fastfetch-cli/fastfetch)
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
| `30-abbreviations.fish` | **Loader** - sources all files from `abbreviations/` |
| `zz-fastfetch.fish` | Fastfetch (after version managers load) |

## Abbreviations (modular)

All abbreviations live in `conf.d/abbreviations/` as separate files per tool category.
The loader `30-abbreviations.fish` sources them all automatically.

```text
config/fish/conf.d/abbreviations/
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
| `dot-files` | Manage style, color, welcome name, modules, and diagnostics |
| `fastfetch-apply-welcome` | Sync `starship/username` into Fastfetch `config.jsonc` |
| `dotfiles-read-setting` | Read the first non-comment line from a preference file |
| `dotfiles-read-modules` | Read every non-comment line from a preference file |
| `nvm` | Node Version Manager helper |

## Fastfetch startup

`zz-fastfetch.fish` calls `fastfetch-apply-welcome` before Fastfetch so the title reflects `~/.config/starship/username`.

## dot-files command reference

Run `dot-files` with no arguments to see active settings and live prompt style/color previews.

```fish
dot-files                              # usage, active settings, previews
dot-files --style 5                    # set prompt separator style 1-5
dot-files --color moonlight            # set color palette
dot-files --username "Alex"            # set Fastfetch welcome name
dot-files --username reset             # back to system username
dot-files --edit style|color|modules|username  # edit preference file

# Modules
dot-files --list-modules
dot-files --enable-module git
dot-files --disable-module file-icons

# Diagnostics
dot-files --doctor                     # run diagnostics
dot-files --status                     # show dotfiles git status

```

### --edit workflow

Open the active preference file for the chosen target and apply any rebuild after
the editor closes:

- `style` / `color` / `modules` - rebuilds the Starship prompt then shows a preview
- `username` - runs `fastfetch-apply-welcome`

## Persistent PATH with `fish_user_paths`

`conf.d/15-paths.fish` creates the universal `fish_user_paths` variable if it
doesn't exist. Tools like `fnm`, `mise`, `cargo`, and `go` write their `bin/`
directories there; Fish prepends them to `PATH` on every shell start and
deduplicates automatically.

```fish
# Example: add cargo to the persistent PATH
set -U fish_user_paths ~/.cargo/bin $fish_user_paths
```

## nvm wrapper

`functions/nvm.fish` lazy-loads Node Version Manager on first call. Because
nvm is a bash-only script, the wrapper delegates to `bash -lc` when nvm has
not already been loaded into the session. The `$NVM_DIR` environment variable
is respected if set.