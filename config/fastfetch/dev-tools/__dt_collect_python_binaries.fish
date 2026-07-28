function __dt_collect_python_binaries
    set -l seen
    for path_dir in $PATH
        if not test -d "$path_dir"
            continue
        end
        for binary in "$path_dir"/python3.*
            if not test -x "$binary"
                continue
            end
            set -l name (command basename "$binary")
            if not string match -qr '^python3\.[0-9]+$' -- "$name"
                continue
            end
            if not contains -- "$binary" $seen
                set -a seen "$binary"
                echo "$binary"
            end
        end
    end
end
