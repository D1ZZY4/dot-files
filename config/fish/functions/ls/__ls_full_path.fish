function __ls_full_path -a target name
    if test "$name" = .
        echo "$target"
    else if test "$name" = ..
        command dirname "$target"
    else if test -d "$target"
        echo "$target/$name"
    else
        echo "$target"
    end
end
