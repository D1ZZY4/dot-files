# Icon-aware ls for Fish when eza/lsd not installed.

for f in (dirname (status --current-filename))/ls/*.fish
    test -f "$f"; and source "$f"
end

function ls --description 'List files with Nerd Font icons' --wraps ls
    if type -q eza
        command eza --icons=always --group-directories-first -- $argv
        return $status
    else if type -q lsd
        command lsd --icon always --group-dirs first -- $argv
        return $status
    end

    set -l show_all 0
    set -l long 0
    set -l paths

    for arg in $argv
        switch $arg
            case -a --all;       set show_all 1
            case -A --almost-all; set show_all 1
            case -l;              set long 1
            case -la -al -lA -Al; set long 1; set show_all 1
            case '-*'
                command ls -- $argv
                return $status
            case '*'
                set -a paths $arg
        end
    end

    if test (count $paths) -eq 0
        set paths .
    end

    set -l multiple 0
    if test (count $paths) -gt 1
        set multiple 1
    end

    for target in $paths
        if test $multiple -eq 1
            echo "$target:"
        end
        if test $long -eq 1
            __ls_long_icons "$target" $show_all
        else
            __ls_column_icons "$target" $show_all
        end
        if test $multiple -eq 1
            echo
        end
    end
end
