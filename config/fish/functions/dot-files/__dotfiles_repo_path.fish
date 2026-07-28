function __dotfiles_repo_path
    set -l curl_path "$HOME/.local/share/dotfiles"
    if test -d "$curl_path"; and git -C "$curl_path" rev-parse --is-inside-work-tree >/dev/null 2>&1
        echo "$curl_path"
        return 0
    end
    if set -q DOTFILES_DIR
        if test -d "$DOTFILES_DIR"; and git -C "$DOTFILES_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1
            echo "$DOTFILES_DIR"
            return 0
        end
    end
    return 1
end
