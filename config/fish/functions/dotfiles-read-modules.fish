# Read every non-comment, non-blank line from a preference file.
function dotfiles-read-modules --argument-names file_path
    if not test -f "$file_path"
        return 1
    end

    while read -l line
        set -l trimmed (string trim -- $line)
        if test -z "$trimmed"; or string match -qr '^\s*#' -- "$trimmed"
            continue
        end
        echo "$trimmed"
    end < "$file_path"
end
