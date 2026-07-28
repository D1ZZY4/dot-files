# Read first non-comment, non-blank line from a preference file.
function dotfiles-read-setting --argument-names file_path
    if not test -f "$file_path"
        return 1
    end

    while read -l line
        set -l trimmed (string trim -- $line)
        if test -z "$trimmed"
            continue
        end
        if string match -qr '^#' -- "$trimmed"
            continue
        end
        echo "$trimmed"
        return 0
    end < "$file_path"

    return 1
end
