function __ls_long_icons -a target show_all
    if test -d "$target"
        command ls -la "$target" 2>/dev/null | command head -n 1
    end
    for name in (__ls_entries "$target" $show_all)
        set -l full (__ls_full_path "$target" "$name")
        if not test -e "$full"; and not test -L "$full"
            continue
        end
        set -l icon (__ls_icon "$name" "$full")
        set -l stat_fields
        set stat_fields (command stat -c '%A %h %U %G %s %y' -- "$full" 2>/dev/null)
        or set stat_fields (command stat -f '%Lp %l %Su %Sg %z %Sm' -- "$full" 2>/dev/null)
        if test -z "$stat_fields"
            continue
        end
        set -l perms (string split ' ' -- "$stat_fields")[1]
        set -l links (string split ' ' -- "$stat_fields")[2]
        set -l user (string split ' ' -- "$stat_fields")[3]
        set -l group (string split ' ' -- "$stat_fields")[4]
        set -l size (string split ' ' -- "$stat_fields")[5]
        set -l mtime (string split ' ' -- "$stat_fields")[6..-1]
        if test (count $mtime) -gt 1
            set mtime (string join ' ' $mtime)
        end
        set -l display "$name"
        if test -L "$full"
            set -l link_target (command readlink "$full" 2>/dev/null)
            set display "$name -> $link_target"
        end
        echo "$perms $links $user $group $size $mtime  $icon  $display"
    end
end
