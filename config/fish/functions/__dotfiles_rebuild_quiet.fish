function __dotfiles_rebuild_quiet
    if not type -q starship
        return 0
    end
    set -l build_fish "$HOME/.config/starship/build.fish"
    if not test -f "$build_fish"
        return 1
    end
    fish "$build_fish" >/dev/null 2>&1
end
