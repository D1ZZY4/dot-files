function __ls_column_icons -a target show_all
    set -l rendered
    for name in (__ls_entries "$target" $show_all)
        set -l full (__ls_full_path "$target" "$name")
        set -l icon (__ls_icon "$name" "$full")
        set -a rendered "$icon  $name"
    end
    if test (count $rendered) -gt 0
        string join \n $rendered | command column
    end
end
