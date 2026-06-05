# Read the first meaningful line from a dotfiles preference file.
# Skips blank lines and lines starting with #.

function dotfiles-read-setting --argument-names file_path
    if not test -f "$file_path"
        return 1
    end

    for line in (cat "$file_path")
        set -l trimmed (string trim -- $line)
        if test -z "$trimmed"
            continue
        end
        if string match -qr '^\s*#' -- "$trimmed"
            continue
        end
        echo "$trimmed"
        return 0
    end

    return 1
end
