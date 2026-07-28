# Usage: __ls_entries <target> <show_all> <treat_file>
# show_all: 0 = no hidden, 1 = show hidden (skip . and ..)
# treat_file: if 1 (or -- -d), don't descend into dir
function __ls_entries -a target show_all
    if test -d "$target"
        if test "$show_all" = 1
            echo .
            echo ..
            command ls -A "$target" 2>/dev/null
        else
            command ls "$target" 2>/dev/null
        end
    else
        command basename "$target"
    end
end
