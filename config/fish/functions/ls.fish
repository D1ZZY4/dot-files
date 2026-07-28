# Guard: interactive only
if not status --is-interactive
    exit 0
end

# Source icon helpers from ls/ subdirectory.
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

    # Parse flags (GNU ls style single-letter combos)
    set -l show_all 0
    set -l long 0
    set -l one_per_line 0
    set -l recurse 0
    set -l dirs_as_files 0
    set -l classify 0
    set -l sort "name"
    set -l reverse 0
    set -l paths

    set -l i 1
    while test $i -le (count $argv)
        set -l arg $argv[$i]
        switch $arg
            case '--all'
                set show_all 1
            case '--almost-all'
                set show_all 1
            case '--help' '--version'
                command ls $argv
                return $status
            case '--*'
                # Long flags not recognized here → pass through to real ls
                command ls $argv
                return $status
            case '-*'
                # Expand single-letter flags from munged combos like -laF
                set -l chars (string split '' -- (string sub -s 2 -- $arg))
                for char in $chars
                    switch $char
                        case a; set show_all 1
                        case A; set show_all 1
                        case l; set long 1
                        case 1; set one_per_line 1
                        case R; set recurse 1
                        case d; set dirs_as_files 1
                        case F; set classify 1
                        case r; set reverse 1
                        case t; set sort "time"
                        case S; set sort "size"
                        case s; set sort "size"
                        case h; # GNU ls -h (human-readable), safe to ignore
                        case '*'
                            # Unknown short flag — pass through to command ls
                            command ls $argv
                            return $status
                    end
                end
            case '*'
                set -a paths $arg
        end
        set i (math $i + 1)
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
        set -l ls_flags
        if test $show_all -eq 1
            set -a ls_flags -A
        end
        if test $dirs_as_files -eq 1
            set -a ls_flags -d
        end
        if test $recurse -eq 1
            set -a ls_flags -R
        end
        if test $one_per_line -eq 1 -a $long -eq 0
            __ls_column_icons "$target" $show_all $one_per_line
        else if test $long -eq 1
            __ls_long_icons "$target" $show_all
        else
            __ls_column_icons "$target" $show_all 0
        end
        if test $multiple -eq 1
            echo
        end
    end
end
