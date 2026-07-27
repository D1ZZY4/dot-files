# Persistent PATH additions via universal `fish_user_paths`.
# Tools like fnm, mise, cargo, go, python venvs, and others append their bin
# directories here. Fish prepends these entries to PATH on every shell startup
# and deduplicates automatically.
# Guarded to interactive shells only: PATH is inherited from the login shell.

if status --is-interactive
    # Create the universal variable if it does not already exist.
    set -q fish_user_paths; or set -U fish_user_paths

# ── Common PATH entries for CachyOS / general Linux ──────────────────────
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
# Add entries from your shell rc or a tool's installer. The universal variable
# survives across sessions and avoids cluttering config.fish with hardcoded paths.
end
