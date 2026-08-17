# Persistent PATH via fish_user_paths.
# fnm, mise, cargo, go, python venvs write their bin dirs here.
# Fish prepends them to PATH on startup and deduplicates.
# Interactive only: PATH inherits from login shell.

if status --is-interactive
    # Lazy-init: skip if already populated (avoids resetting user's list on re-source).
    set -q fish_user_paths; or set -U fish_user_paths

# ── Common PATH entries ────────────────────────────────────────────────
#
# fnm (Fast Node Manager):
#   fnm env --shell fish | source
#
# mise (multi-language version manager):
#   set -U fish_user_paths ~/.local/share/mise/shims $fish_user_paths
#
# cargo (Rust):
#   set -U fish_user_paths ~/.cargo/bin $fish_user_paths
#
# Go:
#   set -U fish_user_paths ~/go/bin $fish_user_paths
#
# Python user scripts:
#   set -U fish_user_paths ~/.local/bin $fish_user_paths
#
# Add entries from your shell rc or tool installer. The universal variable
# survives restarts and keeps config.fish clean.
end
