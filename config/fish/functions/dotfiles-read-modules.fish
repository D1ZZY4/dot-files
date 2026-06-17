# Read every enabled line from a dotfiles preference file.
# Emits each non-blank, non-comment line (trimmed) on its own line.

function dotfiles-read-modules --argument-names file_path
    if not test -f "$file_path"
        return 1
    end

    for line in (cat "$file_path")
        set -l trimmed (string trim -- $line)
        if test -z "$trimmed"; or string match -qr '^#' -- "$trimmed"
            continue
        end
        echo "$trimmed"
    end
end
