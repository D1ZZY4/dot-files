function __dotfiles_doctor
    set -l starship_dir "$HOME/.config/starship"
    set -l color_file "$starship_dir/color"
    set -l modules_file "$starship_dir/modules.conf"
    set -l colors_dir "$starship_dir/colors"
    set -l has_fail 0

    echo "dot-files doctor:"

    if type -q starship
        echo "[OK] starship is on PATH"
    else
        echo "[FAIL] starship is not on PATH" >&2
        set has_fail 1
    end

    if type -q fastfetch
        echo "[OK] fastfetch is on PATH"
    else
        echo "[FAIL] fastfetch is not on PATH" >&2
        set has_fail 1
    end

    if fish -c 'source $HOME/.config/fish/config.fish' >/dev/null 2>&1
        echo "[OK] fish config loads cleanly"
    else
        echo "[FAIL] fish config fails to load" >&2
        set has_fail 1
    end

    set -l color_val (dotfiles-read-setting "$color_file"; or echo moonlight)
    set -l color_theme_file "$colors_dir/$color_val.toml"
    if not test -f "$color_theme_file"
        echo "[WARN] color '$color_val' does not match any theme in colors/" >&2
    else
        echo "[OK] color '$color_val' matches a known theme"
    end

    set -l unknown_modules
    if test -f "$modules_file"
        for mod in (dotfiles-read-modules "$modules_file" 2>/dev/null)
            if not contains -- "$mod" (__dotfiles_all_modules)
                set -a unknown_modules "$mod"
            end
        end
    end
    if test (count $unknown_modules) -eq 0
        echo "[OK] modules.conf references only known modules"
    else
        echo "[WARN] modules.conf contains unknown modules: "(string join ' ' $unknown_modules) >&2
    end

    if test -e "$starship_dir/starship.toml"
        echo "[OK] starship.toml exists"
    else
        echo "[FAIL] starship.toml not found at $starship_dir/starship.toml" >&2
        set has_fail 1
    end

    if test -f "$HOME/.config/fastfetch/config.jsonc"
        echo "[OK] fastfetch config.jsonc exists"
    else
        echo "[FAIL] fastfetch config.jsonc not found at $HOME/.config/fastfetch/config.jsonc" >&2
        set has_fail 1
    end

    return $has_fail
end
