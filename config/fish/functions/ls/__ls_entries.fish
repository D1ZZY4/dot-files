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
