function __dotfiles_edit_file --argument-names file_path
    if not path is -f "$file_path"
        echo "dot-files: $file_path does not exist" >&2
        return 1
    end
    echo "dot-files: editing $file_path"
    if test -n "$EDITOR"
        "$EDITOR" "$file_path"
    else if command -q nvim
        nvim "$file_path"
    else if command -q vim
        vim "$file_path"
    else if command -q nano
        nano "$file_path"
    else
        echo "dot-files: no editor found (set EDITOR)" >&2
        return 1
    end

    return 0
end
