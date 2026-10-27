# Autoload helpers from dot-files/ directory.
# Fish autoloads by filename from functions/, not subdirectories.
for f in (dirname (status --current-filename))/dot-files/*.fish
    test -f "$f"; and source "$f"
end

function dot-files --description 'Manage Starship and Fastfetch dotfiles preferences'
    set -l starship_dir "$HOME/.config/starship"
    set -l build_fish "$starship_dir/build.fish"
    set -l style_file "$starship_dir/style"
    set -l color_file "$starship_dir/color"
    set -l username_file "$starship_dir/username"
    set -l modules_file "$starship_dir/modules.conf"

    if test (count $argv) -eq 0
        __dotfiles_show_catalog "$style_file" "$color_file" "$username_file" "$modules_file"
        return 0
    end

    switch $argv[1]
        case --doctor
            __dotfiles_doctor
            set -l rc $status
            if test $rc -eq 0
                echo "All checks passed."
            else
                echo "$rc check(s) failed." >&2
            end
            return $rc

        case --status
            __dotfiles_status
            return $status

        case --style -s
            if test (count $argv) -lt 2
                echo "dot-files: missing style number" >&2
                return 1
            end
            set -l style $argv[2]
            switch $style
                case 1 2 3 4 5
                    __dotfiles_write_style_file $style "$style_file"
                    fish "$build_fish"
                    echo "Starship style set to $style ($style_file)"
                    echo ""
                    __dotfiles_starship_prompt_block
                case '*'
                    echo "dot-files: unknown style '$style'" >&2
                    echo "Use: 1, 2, 3, 4, or 5"
                    return 1
            end

        case --color -c
            if test (count $argv) -lt 2
                echo "dot-files: missing color theme" >&2
                return 1
            end
            set -l color $argv[2]
            switch $color
                case moonlight catppuccin-macchiato catppuccin-mocha
                    __dotfiles_write_color_file $color "$color_file"
                case '*'
                    echo "dot-files: unknown color theme '$color'" >&2
                    echo "Use: moonlight, catppuccin-macchiato, or catppuccin-mocha"
                    return 1
            end
            fish "$build_fish"
            set -l active_color (dotfiles-read-setting "$color_file")
            echo "Starship color set to $active_color ($color_file)"
            echo ""
            __dotfiles_starship_prompt_block

        case --username -u
            if test (count $argv) -lt 2
                echo "dot-files: missing username (or use: --username reset)" >&2
                return 1
            end
            set -l username $argv[2]
            __dotfiles_username_template > "$username_file"
            if test "$username" != reset -a "$username" != system -a "$username" != default
                echo "$username" >> "$username_file"
            end
            fastfetch-apply-welcome \
                && echo "dot-files: welcome updated ($username_file)" \
                || { echo "dot-files: fastfetch-apply-welcome failed, check ~/.config/fastfetch/config.jsonc" >&2; return 1; }
            return 0

        case --enable-module
            set -l module_name $argv[2]
            __dotfiles_require_valid_module "$module_name"; or return 1
            __dotfiles_init_modules_file "$modules_file"
            if contains -- "$module_name" (dotfiles-read-modules "$modules_file")
                echo "dot-files: module '$module_name' is already enabled"
            else
                set -l escaped (__dotfiles_regex_escape "$module_name")
                sed -i.bak "s/^# *$escaped\$/$module_name/" "$modules_file"
                rm -f "$modules_file.bak"
                echo "dot-files: module '$module_name' enabled"
            end
            fish "$build_fish"
            echo ""
            __dotfiles_starship_prompt_block

        case --disable-module
            set -l module_name $argv[2]
            __dotfiles_require_valid_module "$module_name"; or return 1
            if test "$module_name" = core
                echo "dot-files: cannot disable 'core' module (required)" >&2
                return 1
            end
            __dotfiles_init_modules_file "$modules_file"
            set -l escaped (__dotfiles_regex_escape "$module_name")
            sed -i.bak "s/^$escaped\$/# $module_name/" "$modules_file"
            rm -f "$modules_file.bak"
            echo "dot-files: module '$module_name' disabled"
            fish "$build_fish"
            echo ""
            __dotfiles_starship_prompt_block

        case --list-modules
            set -l enabled (dotfiles-read-modules "$modules_file")
            if not test -f "$modules_file"
                set enabled core directory git languages package
            end
            echo "Available modules (core cannot be disabled):"
            for m in (__dotfiles_all_modules)
                if test "$m" = core
                    echo "  (required) $m"
                else if contains -- "$m" $enabled
                    echo "  (enabled)  $m"
                else
                    echo "  (disabled) $m"
                end
            end
            echo ""
            echo "Use --enable-module or --disable-module to toggle."

        case --edit -e
            set -l edit_target $argv[2]
            switch "$edit_target"
                case style color modules
                    set -l f "$starship_dir/$edit_target"
                    if test "$edit_target" = modules
                        set f "$modules_file"
                    end
                    __dotfiles_edit_file "$f"; or return 1
                    fish "$build_fish"
                    echo ""
                    __dotfiles_starship_prompt_block
                case username
                    __dotfiles_edit_file "$username_file"; or return 1
                    fastfetch-apply-welcome
                    and echo "dot-files: welcome name updated"
                    return 0
                case '*'
                    echo "dot-files: unknown edit target '$edit_target'" >&2
                    echo "Usage: dot-files --edit style|color|modules|username" >&2
                    return 1
            end

        case --ls-style
            if test (count $argv) -lt 2
                echo "dot-files: missing ls style number" >&2
                echo "Use: 1 (grid), 2 (one-per-line), 3 (tree), 4 (git+header), 5 (git), 6 (loc)" >&2
                return 1
            end
            switch $argv[2]
                case 1 2 3 4 5 6
                    echo "# eza ls output style (1|2|3|4|5|6)" > "$starship_dir/ls-style"
                    echo "$argv[2]" >> "$starship_dir/ls-style"
                    echo "dot-files: ls style set to $argv[2] ($starship_dir/ls-style)"
                    echo "Restart shell or exec fish to apply."
                case '*'
                    echo "dot-files: unknown ls style '$argv[2]'" >&2
                    echo "Use: 1 (grid), 2 (one-per-line), 3 (tree), 4 (git+header), 5 (git), 6 (loc)" >&2
                    return 1
            end

        case --ll-style
            if test (count $argv) -lt 2
                echo "dot-files: missing ll style number" >&2
                echo "Use: 1, 2, 3 (git), 4 (header+group+iso), 5 (inode), 6 (color-scale)" >&2
                return 1
            end
            switch $argv[2]
                case 1 2 3 4 5 6
                    echo "# eza ll output style (1|2|3|4|5|6)" > "$starship_dir/ll-style"
                    echo "$argv[2]" >> "$starship_dir/ll-style"
                    echo "dot-files: ll style set to $argv[2] ($starship_dir/ll-style)"
                    echo "Restart shell or exec fish to apply."
                case '*'
                    echo "dot-files: unknown ll style '$argv[2]'" >&2
                    echo "Use: 1, 2, 3 (git), 4 (header+group+iso), 5 (inode), 6 (color-scale)" >&2
                    return 1
            end

        case --ls-group
            if test (count $argv) -lt 2
                echo "dot-files: missing --ls-group value" >&2
                echo "Use: on or off" >&2
                return 1
            end
            switch $argv[2]
                case on off
                    echo "# Group directories first (on|off)" > "$starship_dir/ls-group"
                    echo "$argv[2]" >> "$starship_dir/ls-group"
                    echo "dot-files: ls group-directories-first set to $argv[2]"
                    echo "Restart shell or exec fish to apply."
                case '*'
                    echo "dot-files: unknown value '$argv[2]'" >&2
                    echo "Use: on or off" >&2
                    return 1
            end

        case '*'
            echo "dot-files: unknown option '$argv[1]'" >&2
            echo "Run 'dot-files' to see usage."
            return 1
    end
end
