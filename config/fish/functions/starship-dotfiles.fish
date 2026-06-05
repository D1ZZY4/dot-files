# Manage dotfiles preferences: Starship style/color and Fastfetch welcome name.
#
# Preference files (installed under ~/.config/starship/):
#   style     — separator style 1-5
#   color     — moonlight | catppuccin-macchiato
#   username  — Fastfetch welcome name (empty = system username)

function __dotfiles_username_template
    printf '%s\n' \
        '# Fastfetch welcome name (optional).' \
        '# Leave empty (comments only) for system username: Welcome, {user-name}!' \
        '# Or add one display name on its own line below.'
end

function __dotfiles_write_style_file --argument-names style path
    printf '%s\n' \
        '# Starship powerline separator style (1-5).' \
        '# 1: block  2: gradient  3: angled  4: slant  5: round (default)' \
        $style > $path
end

function __dotfiles_write_color_file --argument-names color path
    switch $color
        case catppuccin-machiato
            set color catppuccin-macchiato
        case '*'
    end

    printf '%s\n' \
        '# Starship color palette name. Must match colors/<name>.toml' \
        '# Options: moonlight | catppuccin-macchiato' \
        $color > $path
end

function __dotfiles_rebuild_quiet
    fish "$HOME/.config/starship/build.fish" >/dev/null 2>&1
end

function __dotfiles_starship_prompt_block
    set -l config "$HOME/.config/starship.toml"
    set -l term $TERM
    if test -z "$term"; or test "$term" = dumb
        set term xterm-256color
    end

    set -l lines (
        env TERM="$term" STARSHIP_CONFIG="$config" command starship prompt --terminal-width 200 2>/dev/null \
            | string collect \
            | string trim --right -- \
            | string split \n
    )

    # Drop Starship's leading terminal clear sequence; keep the real prompt lines.
    if test (count $lines) -ge 2
        set lines $lines[2..-1]
    end

    string trim --right -- (string join \n $lines)
end

function __dotfiles_print_prompt_preview --argument-names label
    echo "  $label"
    for line in (string split \n (__dotfiles_starship_prompt_block))
        echo "    $line"
    end
end

function __dotfiles_active_marker --argument-names value active
    if test "$value" = "$active"
        echo (set_color green)"*"(set_color normal)
    end
end

function __dotfiles_show_catalog --argument-names style_file color_file username_file
    set -l heading (set_color --bold)
    set -l muted (set_color brblack)
    set -l normal (set_color normal)

    set -l saved_style (dotfiles-read-setting "$style_file"; or echo 5)
    set -l saved_color (dotfiles-read-setting "$color_file"; or echo moonlight)
    set -l active_username (dotfiles-read-setting "$username_file")
    if test -z "$active_username"
        set active_username "(system: {user-name})"
    end

    echo "$heading""Usage$normal"
    echo "  starship-dotfiles --style 1|2|3|4|5"
    echo "  starship-dotfiles --color moonlight|catppuccin-macchiato"
    echo "  starship-dotfiles --username NAME"
    echo "  starship-dotfiles --username reset"
    echo ""
    echo "$heading""Active$normal"
    echo "  style:    $saved_style"
    echo "  color:    $saved_color"
    echo "  username: $active_username"
    echo ""
    echo "$heading""Preference files$normal"
    echo "  $style_file"
    echo "  $color_file"
    echo "  $username_file"
    echo ""
    echo "$heading""Styles$normal $muted(real prompt from your shell · * = active)$normal"

    for style in 1 2 3 4 5
        __dotfiles_write_style_file $style "$style_file"
        __dotfiles_rebuild_quiet
        set -l marker (__dotfiles_active_marker $style $saved_style)
        __dotfiles_print_prompt_preview "$marker$style"
    end

    echo ""
    echo "$heading""Colors$normal $muted(style 5 · real prompt · * = active)$normal"
    __dotfiles_write_style_file 5 "$style_file"

    for color in moonlight catppuccin-macchiato
        __dotfiles_write_color_file $color "$color_file"
        __dotfiles_rebuild_quiet
        set -l marker (__dotfiles_active_marker $color $saved_color)
        __dotfiles_print_prompt_preview "$marker$color"
    end

    __dotfiles_write_style_file $saved_style "$style_file"
    __dotfiles_write_color_file $saved_color "$color_file"
    __dotfiles_rebuild_quiet

    echo ""
    echo "$heading""Fastfetch welcome$normal"
    set -l yellow (set_color yellow)
    echo "  $muted(system)$normal  Welcome, $yellow"{user-name}"$normal!"
    echo "  $muted(custom)$normal   Welcome, "$yellow"Alex"$normal"!"
end

function starship-dotfiles --description 'Manage Starship and Fastfetch dotfiles preferences'
    set -l starship_dir "$HOME/.config/starship"
    set -l style_file "$starship_dir/style"
    set -l color_file "$starship_dir/color"
    set -l username_file "$starship_dir/username"

    if test (count $argv) -eq 0
        __dotfiles_show_catalog "$style_file" "$color_file" "$username_file"
        return 0
    end

    switch $argv[1]
        case --style -s
            if test (count $argv) -lt 2
                echo "starship-dotfiles: missing style number" >&2
                return 1
            end

            set -l style $argv[2]
            switch $style
                case 1 2 3 4 5
                    __dotfiles_write_style_file $style "$style_file"
                    starship-rebuild
                    echo "Starship style set to $style ($style_file)"
                    echo ""
                    __dotfiles_starship_prompt_block
                case '*'
                    echo "starship-dotfiles: unknown style '$style'" >&2
                    echo "Use: 1, 2, 3, 4, or 5"
                    return 1
            end

        case --color -c
            if test (count $argv) -lt 2
                echo "starship-dotfiles: missing color theme" >&2
                return 1
            end

            set -l color $argv[2]
            switch $color
                case moonlight catppuccin-macchiato catppuccin-machiato
                    __dotfiles_write_color_file $color "$color_file"
                case '*'
                    echo "starship-dotfiles: unknown color theme '$color'" >&2
                    echo "Use: moonlight or catppuccin-macchiato"
                    return 1
            end

            starship-rebuild
            echo "Starship color set to "(dotfiles-read-setting "$color_file")" ($color_file)"
            echo ""
            __dotfiles_starship_prompt_block

        case --username -u
            if test (count $argv) -lt 2
                echo "starship-dotfiles: missing username (or use: --username reset)" >&2
                return 1
            end

            set -l username $argv[2]
            if test "$username" = reset -o "$username" = system -o "$username" = default
                __dotfiles_username_template > "$username_file"
                fastfetch-apply-welcome
                echo "Fastfetch welcome uses system username ($username_file cleared)"
                return 0
            end

            __dotfiles_username_template > "$username_file"
            echo "$username" >> "$username_file"
            fastfetch-apply-welcome
            echo "Fastfetch welcome set to: Welcome, $username!"
            echo "Saved in $username_file"

        case '*'
            echo "starship-dotfiles: unknown option '$argv[1]'" >&2
            echo "Run 'starship-dotfiles' to see usage."
            return 1
    end
end
