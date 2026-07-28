#!/usr/bin/env sh
# Dotfiles installer (Fish shell). Installs config/ into ~/.config.
# Supports clone and curl installs. Backs up replaced files.

set -eu

DOTFILES_DIR=${DOTFILES_DIR:-}
DOTFILES_REPO_URL=${DOTFILES_REPO_URL:-https://github.com/D1ZZY4/dot-files.git}
INSTALL_MODE=${INSTALL_MODE:-symlink}
BACKUP_DIR=${BACKUP_DIR:-"$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"}
DRY_RUN=${DRY_RUN:-0}
# Accept 1, true, yes, on as truthy
is_dry_run() { case "${DRY_RUN}" in 1|true|yes|on) return 0 ;; *) return 1 ;; esac }
DOTFILES_WELCOME_NAME=${DOTFILES_WELCOME_NAME:-}

print_usage() {
  cat <<'EOF'
Usage: ./install.sh [options]

Options:
  --copy              Copy files instead of creating symlinks.
  --symlink           Create symlinks (default).
  --dry-run           Show planned changes without modifying the system.
  --welcome NAME      Set Fastfetch welcome title (writes ~/.config/starship/username).
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

  # $0 is unreliable with curl | sh. [ -t 0 ] detects pipe vs terminal.
  if [ ! -t 0 ] && [ -n "$DOTFILES_REPO_URL" ]; then
    :
  else
    script_dir_resolved=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
    if [ -d "$script_dir_resolved/config" ]; then
      echo "$script_dir_resolved"
      return
    fi
  fi

  if [ -n "$DOTFILES_REPO_URL" ]; then
    clone_dir_resolved="$HOME/.local/share/dotfiles"
    info "Cloning from $DOTFILES_REPO_URL to $clone_dir_resolved"
    if [ -d "$clone_dir_resolved" ]; then
      info "Resetting existing clone at $clone_dir_resolved"
      run rm -rf "$clone_dir_resolved"
    fi
    run mkdir -p "$(dirname "$clone_dir_resolved")"
    if ! run git clone --depth 1 "$DOTFILES_REPO_URL" "$clone_dir_resolved"; then
      echo "Failed to clone repository from $DOTFILES_REPO_URL" >&2
      exit 1
    fi
    echo "$clone_dir_resolved"
    return
  fi

  echo "Unable to locate dotfiles source directory." >&2
  echo "Clone the repository first or set DOTFILES_REPO_URL for curl-based installation." >&2
  exit 1
}

backup_path() {
  target_path=$1

  if [ -e "$target_path" ] || [ -L "$target_path" ]; then
    backup_relative=${target_path#"$HOME"/}
    backup_target_path="$BACKUP_DIR/$backup_relative"
    info "Backing up $target_path -> $backup_target_path"
    run mkdir -p "$(dirname "$backup_target_path")"
    run mv -- "$target_path" "$backup_target_path"
  fi
}

install_file() {
  install_src=$1
  install_dst=$2

  if [ ! -e "$install_src" ]; then
    info "Skipping missing source: $install_src"
    return
  fi

  run mkdir -p "$(dirname "$install_dst")"
  backup_path "$install_dst"

  if [ "$INSTALL_MODE" = copy ]; then
    info "Copying $install_src -> $install_dst"
    run cp "$install_src" "$install_dst"
  else
    info "Linking $install_src -> $install_dst"
    run ln -s "$install_src" "$install_dst"
  fi
}

install_tree_files() {
  tree_source_dir=$1
  tree_target_dir=$2

  if [ ! -d "$tree_source_dir" ]; then
    return
  fi

  find "$tree_source_dir" -type f | while IFS= read -r tree_source_file; do
    tree_relative=${tree_source_file#"$tree_source_dir"/}
    install_file "$tree_source_file" "$tree_target_dir/$tree_relative"
  done
}

write_welcome_name() {
  welcome_name=$1
  welcome_target=$2

  if [ -z "$welcome_name" ]; then
    return 0
  fi

  info "Setting Fastfetch welcome name: $welcome_name"
  if is_dry_run; then
    echo "[dry-run] write welcome name to $welcome_target"
    return 0
  fi

  run mkdir -p "$(dirname "$welcome_target")"
  backup_path "$welcome_target"
  {
    printf '%s\n' \
      '# Fastfetch welcome name (optional).' \
      '# Leave empty (comments only) for system username: Welcome, {user-name}!' \
      '# Or add one display name on its own line below.'
    printf '%s\n' "$welcome_name"
  } >"$welcome_target"
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

info "Installation complete. Restart Fish or run: exec fish"
