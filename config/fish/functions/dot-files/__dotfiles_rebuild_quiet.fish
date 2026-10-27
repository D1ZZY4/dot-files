# Cache starship.toml content hash to skip redundant rebuilds.
# Always rebuild when preview env vars are set (catalog previews need fresh output).
if not set -q __dotfiles_build_hash
    set -g __dotfiles_build_hash
end

function __dotfiles_rebuild_quiet
    if not command -q starship
        return 0
    end
    set -l build_fish "$HOME/.config/starship/build.fish"
    if not path is -f "$build_fish"
        return 1
    end
    # Skip cache when preview env vars are active (catalog previews).
    if set -q STARSHIP_STYLE_PREVIEW; or set -q STARSHIP_COLOR_PREVIEW
        source "$build_fish" >/dev/null 2>&1
        return
    end
    # Only rebuild if source prefs changed since last build.
    # Fingerprint the three pref files directly (no cat/cut, no brace
    # expansion - fish has none; the literal {a,b} was never hashed).
    set -l prefs_dir "$HOME/.config/starship"
    set -l current_hash (sha256sum "$prefs_dir/style" "$prefs_dir/color" "$prefs_dir/modules.conf" 2>/dev/null | string collect)
    if test "$current_hash" = "$__dotfiles_build_hash"
        return 0
    end
    set -g __dotfiles_build_hash "$current_hash"
    source "$build_fish" >/dev/null 2>&1
end
