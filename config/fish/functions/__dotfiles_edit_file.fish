function __dotfiles_edit_file --argument-names file_path
    if not test -f "$file_path"
        echo "dot-files: $file_path does not exist" >&2
        return 1
    end
    echo "dot-files: editing $file_path"
    if set -q EDITOR
        if test -n "$EDITOR"
            "$EDITOR" "$file_path"
        else
            echo "dot-files: EDITOR is set but empty" >&2
            return 1
        end
    else if type -q nvim
        nvim "$file_path"
    else if type -q vim
        vim "$file_path"
    else if type -q nano
        nano "$file_path"
    else
        echo "dot-files: no editor found (set EDITOR)" >&2
        return 1
    end
end
