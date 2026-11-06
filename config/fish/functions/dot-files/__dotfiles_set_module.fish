# Toggle a module in modules.conf (one module per line, '# name' disables).
# mode: 'on' to enable, 'off' to disable.
# Creates the file with defaults if missing. All unrelated lines (comments,
# blanks) are preserved verbatim.
# Exit codes: 0 = changed, 1 = already in the desired state, 2 = error.
function __dotfiles_set_module --argument-names module_name mode file_path
    if not contains -- "$mode" on off
        echo "__dotfiles_set_module: mode must be 'on' or 'off'" >&2
        return 2
    end

    __dotfiles_init_modules_file "$file_path"
    if not path is -r "$file_path"
        echo "dot-files: cannot read $file_path" >&2
        return 2
    end

    set -l content (string collect < "$file_path")
    set -l lines (string split \n -- "$content")
    # A trailing newline yields a final empty element; drop it, keep interior blanks.
    if test (count $lines) -gt 0; and test -z "$lines[-1]"
        set -e lines[-1]
    end

    set -l escaped_name (string escape --style=regex -- "$module_name")
    set -l changed 0
    set -l found 0
    set -l out

    for line in $lines
        set -l trimmed (string trim -- "$line")
        if string match -qr "^(# *)?$escaped_name\$" -- "$trimmed"
            set found 1
            if test "$mode" = on
                if string match -qr "^#" -- "$trimmed"
                    set -a out "$module_name"
                    set changed 1
                else
                    set -a out "$line"
                end
            else
                if string match -qr "^#" -- "$trimmed"
                    set -a out "$line"
                else
                    set -a out "# $module_name"
                    set changed 1
                end
            end
        else
            set -a out "$line"
        end
    end

    # Module line was missing entirely (hand-edited file): append the canonical entry.
    if test $found -eq 0
        if test "$mode" = on
            set -a out "$module_name"
            set changed 1
        end
    end

    if test $changed -eq 0
        return 1
    end

    printf '%s\n' $out > "$file_path"
    return 0
end
