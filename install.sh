#!/usr/bin/env sh
# Dotfiles installer (Fish shell). Installs config/fish, starship, and fastfetch into ~/.config.
# Supports clone-based and curl-based installs. Backs up replaced files before overwriting.

set -eu

DOTFILES_DIR=${DOTFILES_DIR:-}
DOTFILES_REPO_URL=${DOTFILES_REPO_URL:-https://github.com/D1ZZY4/dot-files.git}
INSTALL_MODE=${INSTALL_MODE:-symlink}
BACKUP_DIR=${BACKUP_DIR:-"$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"}
DRY_RUN=${DRY_RUN:-0}
# Accept common truthy values: 1, true, yes, on
is_dry_run() { case "${DRY_RUN}" in 1|true|yes|on) return 0 ;; *) return 1 ;; esac }
DOTFILES_WELCOME_NAME=${DOTFILES_WELCOME_NAME:-}
AGENTS_MODE=${AGENTS_MODE:-}  # all | comma-separated list | empty (skip)

print_usage() {
  cat <<'EOF'
Usage: ./install.sh [options]

Options:
  --copy              Copy files instead of creating symlinks.
  --symlink           Create symlinks (default).
  --dry-run           Show planned changes without modifying the system.
  --welcome NAME      Set Fastfetch welcome title (writes ~/.config/starship/username).
  --agents VALUE      Install optional skills from agents/ (all, <name>, or <name1,name2>).
  --help              Show this help message.

Environment variables:
  DOTFILES_DIR          Explicit dotfiles checkout path.
  DOTFILES_REPO_URL     Repository URL for curl-based installation.
  DOTFILES_WELCOME_NAME Same as --welcome (custom Fastfetch title).
  BACKUP_DIR            Backup location for replaced files.
  INSTALL_MODE          symlink or copy.

Preference files after install:
  ~/.config/starship/style      Starship separator style (1-5)
  ~/.config/starship/color      Starship palette name
  ~/.config/starship/username   Fastfetch welcome name (empty = system user)
  ~/.config/starship/modules.conf    Enabled Starship modules (one per line; # disables)
  ~/.config/starship/dev-tools.toml  Dev Tools visibility

Examples:
  ./install.sh
  ./install.sh --welcome "Alex"
  ./install.sh --copy
  curl -fsSL https://raw.githubusercontent.com/D1ZZY4/dot-files/main/install.sh | sh
  curl -fsSL .../install.sh | sh -s -- --welcome "Alex"
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --copy)
      INSTALL_MODE=copy
      ;;
    --symlink)
      INSTALL_MODE=symlink
      ;;
    --dry-run)
      DRY_RUN=1
      ;;
    --welcome)
      shift
      if [ "$#" -eq 0 ]; then
        echo "install.sh: --welcome requires a name" >&2
        exit 1
      fi
      DOTFILES_WELCOME_NAME="$1"
      ;;
    --agents)
      shift
      if [ "$#" -eq 0 ]; then
        echo "install.sh: --agents requires a value (all, <name>, or <name1,name2>)" >&2
        exit 1
      fi
      AGENTS_MODE="$1"
      ;;
    --help|-h)
      print_usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      print_usage
      exit 1
      ;;
  esac
  shift
done

run() {
  if is_dry_run; then
    echo "[dry-run] $*"
  else
    "$@"
  fi
}

info() {
  echo "[dotfiles] $*"
}

resolve_source_dir() {
  if [ -n "$DOTFILES_DIR" ]; then
    echo "$DOTFILES_DIR"
    return
  fi

  # $0 is unreliable when piped (e.g. curl | sh). Skip directly to the clone
  # path if stdin is not a regular file (script is being read from a pipe).
  if [ ! -f /dev/stdin ] && [ -n "$DOTFILES_REPO_URL" ]; then
    :
  else
    local script_dir
    script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
    if [ -d "$script_dir/config" ]; then
      echo "$script_dir"
      return
    fi
  fi

  if [ -n "$DOTFILES_REPO_URL" ]; then
    local clone_dir="$HOME/.local/share/dotfiles"
    info "Cloning from $DOTFILES_REPO_URL to $clone_dir"
    if [ -d "$clone_dir" ]; then
      info "Resetting existing clone at $clone_dir"
      run rm -rf "$clone_dir"
    fi
    run mkdir -p "$(dirname "$clone_dir")"
    if ! run git clone --depth 1 "$DOTFILES_REPO_URL" "$clone_dir"; then
      echo "Failed to clone repository from $DOTFILES_REPO_URL" >&2
      exit 1
    fi
    echo "$clone_dir"
    return
  fi

  echo "Unable to locate dotfiles source directory." >&2
  echo "Clone the repository first or set DOTFILES_REPO_URL for curl-based installation." >&2
  exit 1
}

backup_path() {
  local target=$1

  if [ -e "$target" ] || [ -L "$target" ]; then
    local relative=${target#"$HOME"/}
    local backup_target="$BACKUP_DIR/$relative"
    info "Backing up $target -> $backup_target"
    run mkdir -p "$(dirname "$backup_target")"
    run mv -- "$target" "$backup_target"
  fi
}

install_file() {
  local source=$1
  local target=$2

  if [ ! -e "$source" ]; then
    info "Skipping missing source: $source"
    return
  fi

  run mkdir -p "$(dirname "$target")"
  backup_path "$target"

  if [ "$INSTALL_MODE" = copy ]; then
    info "Copying $source -> $target"
    run cp "$source" "$target"
  else
    info "Linking $source -> $target"
    run ln -s "$source" "$target"
  fi
}

install_tree_files() {
  local source_dir=$1
  local target_dir=$2

  if [ ! -d "$source_dir" ]; then
    return
  fi

  while IFS= read -r source_file; do
    local relative=${source_file#"$source_dir"/}
    install_file "$source_file" "$target_dir/$relative"
  done < <(find "$source_dir" -type f)
}

write_welcome_name() {
  local name=$1
  local target=$2

  if [ -z "$name" ]; then
    return 0
  fi

  info "Setting Fastfetch welcome name: $name"
  if is_dry_run; then
    echo "[dry-run] write welcome name to $target"
    return 0
  fi

  run mkdir -p "$(dirname "$target")"
  backup_path "$target"
  {
    printf '%s\n' \
      '# Fastfetch welcome name (optional).' \
      '# Leave empty (comments only) for system username: Welcome, {user-name}!' \
      '# Or add one display name on its own line below.'
    printf '%s\n' "$name"
  } >"$target"
}

# ---------------------------------------------------------------------------
# Agents / Skills system
# ---------------------------------------------------------------------------

list_agents() {
  local agents_dir="$1"
  if [ ! -d "$agents_dir" ]; then
    return
  fi
  info "Available skills in agents/:"
  local found=0
  for skill_dir in "$agents_dir"/*; do
    [ -d "$skill_dir" ] || continue
    local skill_name
    skill_name=$(basename "$skill_dir")
    [ "$skill_name" = ".git" ] && continue
    local desc=""
    if [ -f "$skill_dir/description.md" ]; then
      desc=$(head -n 1 "$skill_dir/description.md" | tr -d '\r')
    fi
    if [ -n "$desc" ]; then
      info "  $skill_name: $desc"
    else
      info "  $skill_name"
    fi
    found=$((found + 1))
  done
  if [ "$found" -eq 0 ]; then
    info "  (none — agents/ is empty)"
  fi
}

install_agent() {
  local skill_name="$1"
  local agents_dir="$SOURCE_DIR/agents"
  local skill_dir="$agents_dir/$skill_name"
  if [ ! -d "$skill_dir" ]; then
    info "Skipping unknown skill: $skill_name"
    return
  fi
  if [ ! -f "$skill_dir/install.fish" ]; then
    info "Skipping $skill_name: no install.fish"
    return
  fi
  info "Installing skill: $skill_name"
  if is_dry_run; then
    echo "[dry-run] fish -c 'source $skill_dir/install.fish'"
  else
    fish -c "source '$skill_dir/install.fish'" 2>&1
  fi
}

install_agents() {
  if [ -z "$AGENTS_MODE" ]; then
    return
  fi
  local agents_dir="$SOURCE_DIR/agents"
  if [ ! -d "$agents_dir" ]; then
    info "agents/ directory not found in source — skipping skills"
    return
  fi
  echo ""
  info "Skills selection"
  list_agents "$agents_dir"
  echo ""

  case "$AGENTS_MODE" in
    all)
      info "Installing all skills..."
      for skill_dir in "$agents_dir"/*; do
        [ -d "$skill_dir" ] || continue
        install_agent "$(basename "$skill_dir")"
      done
      ;;
    *)
      info "Installing selected skills: $AGENTS_MODE"
      local IFS=','
      for skill_name in $AGENTS_MODE; do
        skill_name=$(echo "$skill_name" | tr -d '[:space:]')
        [ -z "$skill_name" ] && continue
        install_agent "$skill_name"
      done
      ;;
  esac
  echo ""
}

SOURCE_DIR=$(resolve_source_dir)
CONFIG_HOME=${XDG_CONFIG_HOME:-"$HOME/.config"}

info "Source directory: $SOURCE_DIR"
info "Config directory: $CONFIG_HOME"
info "Install mode: $INSTALL_MODE"

run mkdir -p "$CONFIG_HOME"

install_tree_files "$SOURCE_DIR/config/fish" "$CONFIG_HOME/fish"
install_tree_files "$SOURCE_DIR/config/starship" "$CONFIG_HOME/starship"
install_tree_files "$SOURCE_DIR/config/fastfetch" "$CONFIG_HOME/fastfetch"

if [ -n "$DOTFILES_WELCOME_NAME" ]; then
  write_welcome_name "$DOTFILES_WELCOME_NAME" "$CONFIG_HOME/starship/username"
fi

if command -v fish >/dev/null 2>&1; then
  if [ -n "$DOTFILES_WELCOME_NAME" ]; then
    info "Applying Fastfetch welcome title"
    if is_dry_run; then
      echo "[dry-run] fish -c 'fastfetch-apply-welcome'"
    else
      fish -c 'fastfetch-apply-welcome'
    fi
  fi

  info "Generating Starship config"
  if is_dry_run; then
    echo "[dry-run] fish $CONFIG_HOME/starship/build.fish"
  else
    fish "$CONFIG_HOME/starship/build.fish"
  fi
else
  info "Fish is not installed; skipping welcome apply and Starship generation."
  info "Run later: fish -c fastfetch-apply-welcome; fish ~/.config/starship/build.fish"
fi

install_file "$CONFIG_HOME/starship/starship.toml" "$CONFIG_HOME/starship.toml"

install_agents

info "Installation complete. Restart Fish or run: exec fish"
