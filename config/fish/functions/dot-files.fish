# Manage dotfiles preferences: Starship style/color, Fastfetch welcome, dev-tools, and modules.
#
# Preference files (installed under ~/.config/starship/):
#   style      — separator style 1-5
#   color      — moonlight | catppuccin-macchiato
#   username   — Fastfetch welcome name (empty = system username)
#   dev-tools.toml — controls which dev tools are shown
#   modules.conf   — one module name per line; a leading # disables that module

function __dotfiles_all_modules
    printf '%s\n' core directory git languages package file-icons
end

# Create modules.conf with every module enabled (file-icons disabled by default)
# if it does not already exist. build.fish reads this file to order the prompt.
function __dotfiles_init_modules_file --argument-names modules_file
    if test -f "$modules_file"
        return 0
    end
    for module in (__dotfiles_all_modules)
        if test "$module" = file-icons
            echo "# $module"
        else
            echo "$module"
        end
    end > "$modules_file"
end

function __dotfiles_require_valid_module --argument-names module_name
    if test -z "$module_name"
        echo "dot-files: missing module name" >&2
        echo "Available: "(string join ' ' (__dotfiles_all_modules)) >&2
        return 1
    end
    if not contains -- "$module_name" (__dotfiles_all_modules)
        echo "dot-files: unknown module '$module_name'" >&2
        echo "Available: "(string join ' ' (__dotfiles_all_modules)) >&2
        return 1
    end
end

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

    if test (count $lines) -ge 2
        set lines $lines[2..-1]
    end

    string trim --right -- (string join \n $lines)
    return 0
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

function __dotfiles_show_catalog --argument-names style_file color_file username_file modules_file
    set -l heading (set_color --bold)
    set -l muted (set_color brblack)
    set -l normal (set_color normal)

    set -l saved_style (dotfiles-read-setting "$style_file"; or echo 5)
    set -l saved_color (dotfiles-read-setting "$color_file"; or echo moonlight)
    set -l active_username (dotfiles-read-setting "$username_file")
    if test -z "$active_username"
        set active_username "(system: {user-name})"
    end

    set -l enabled_modules (dotfiles-read-modules "$modules_file")

    echo "$heading""Usage$normal"
    echo "  dot-files --style 1|2|3|4|5"
    echo "  dot-files --color moonlight|catppuccin-macchiato"
    echo "  dot-files --username NAME"
    echo "  dot-files --username reset"
    echo "  dot-files --enable-module core|directory|git|languages|package|file-icons"
    echo "  dot-files --disable-module core|directory|git|languages|package|file-icons"
    echo "  dot-files --list-modules"
    echo "  dot-files --dev-tools init"
    echo "  dot-files --dev-tools toggle <tool>"
    echo ""
    echo "$heading""Active$normal"
    echo "  style:    $saved_style"
    echo "  color:    $saved_color"
    echo "  username: $active_username"
    if test (count $enabled_modules) -gt 0
        echo "  modules:  "(string join ', ' $enabled_modules)
    else
        echo "  modules:  (all enabled)"
    end
    echo ""
    echo "$heading""Preference files$normal"
    echo "  $style_file"
    echo "  $color_file"
    echo "  $username_file"
    echo "  $modules_file"
    echo ""
    echo "$heading""Styles$normal $muted(real prompt from your shell · * = active)$normal"

    for style_check in 1 2 3 4 5
        __dotfiles_write_style_file $style_check "$style_file"
        __dotfiles_rebuild_quiet
        set -l marker (__dotfiles_active_marker $style_check $saved_style)
        __dotfiles_print_prompt_preview "$marker$style_check"
    end

    echo ""
    echo "$heading""Colors$normal $muted(style 5 · real prompt · * = active)$normal"
    __dotfiles_write_style_file 5 "$style_file"

    for color_check in moonlight catppuccin-macchiato
        __dotfiles_write_color_file $color_check "$color_file"
        __dotfiles_rebuild_quiet
        set -l marker (__dotfiles_active_marker $color_check $saved_color)
        __dotfiles_print_prompt_preview "$marker$color_check"
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

function dot-files --description 'Manage Starship and Fastfetch dotfiles preferences'
    set -l starship_dir "$HOME/.config/starship"
    set -l style_file "$starship_dir/style"
    set -l color_file "$starship_dir/color"
    set -l username_file "$starship_dir/username"
    set -l modules_file "$starship_dir/modules.conf"
    set -l devtools_file "$starship_dir/dev-tools.toml"

    if test (count $argv) -eq 0
        __dotfiles_show_catalog "$style_file" "$color_file" "$username_file" "$modules_file"
        return 0
    end

    switch $argv[1]
        case --style -s
            if test (count $argv) -lt 2
                echo "dot-files: missing style number" >&2
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
                case moonlight catppuccin-macchiato
                    __dotfiles_write_color_file $color "$color_file"
                case '*'
                    echo "dot-files: unknown color theme '$color'" >&2
                    echo "Use: moonlight or catppuccin-macchiato"
                    return 1
            end

            starship-rebuild
            echo "Starship color set to "(dotfiles-read-setting "$color_file")" ($color_file)"
            echo ""
            __dotfiles_starship_prompt_block

        case --username -u
            if test (count $argv) -lt 2
                echo "dot-files: missing username (or use: --username reset)" >&2
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

        case --enable-module
            set -l module_name $argv[2]
            __dotfiles_require_valid_module "$module_name"; or return 1
            __dotfiles_init_modules_file "$modules_file"

            if contains -- "$module_name" (dotfiles-read-modules "$modules_file")
                echo "dot-files: module '$module_name' is already enabled"
            else
                sed -i "s/^# *$module_name\$/$module_name/" "$modules_file"
                echo "dot-files: module '$module_name' enabled"
            end
            starship-rebuild
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
            sed -i "s/^$module_name\$/# $module_name/" "$modules_file"
            echo "dot-files: module '$module_name' disabled"
            starship-rebuild
            echo ""
            __dotfiles_starship_prompt_block

        case --list-modules
            set -l enabled (dotfiles-read-modules "$modules_file")
            if not test -f "$modules_file"
                # No preference file yet: report the built-in defaults.
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

        case --dev-tools
            if test (count $argv) -lt 2
                echo "dot-files: missing dev-tools action" >&2
                echo "Usage: dot-files --dev-tools init" >&2
                echo "       dot-files --dev-tools toggle <tool_name>" >&2
                return 1
            end

            set -l dt_action $argv[2]

            if test "$dt_action" = init
                if not test -f "$devtools_file"
                    printf '%s\n' \
                        '# Dev Tools visibility for the Fastfetch startup block.' \
                        '# Set a tool to false to hide it (for example: docker = false).' \
                        '# Tools that are not installed are omitted regardless.' \
                        '# Updated via: dot-files --dev-tools toggle <tool>' \
                        '' \
                        '[runtimes]' \
                        'nodejs = true' \
                        'deno = true' \
                        'bun = true' \
                        'go = true' \
                        'rustc = true' \
                        'java = true' \
                        '' \
                        '[packages]' \
                        'npm = true' \
                        'pnpm = true' \
                        'yarn = true' \
                        'cargo = true' \
                        'pipx = true' \
                        'uv = true' \
                        '' \
                        '[python]' \
                        'python = true' \
                        '' \
                        '[system_tools]' \
                        'git = true' \
                        'gh = true' \
                        '' \
                        '[infrastructure]' \
                        'docker = true' \
                        'compose = true' \
                        'kubectl = true' \
                        > "$devtools_file"
                    echo "dot-files: dev-tools config created at $devtools_file"
                else
                    echo "dot-files: dev-tools config already exists at $devtools_file"
                end
                return 0
            end

            if test "$dt_action" = toggle
                if test (count $argv) -lt 3
                    echo "dot-files: missing tool name for toggle" >&2
                    echo "Tools: nodejs deno bun go rustc java npm pnpm yarn cargo pipx uv python git gh docker compose kubectl" >&2
                    return 1
                end

                set -l tool_name $argv[3]
                if not test -f "$devtools_file"
                    echo "dot-files: dev-tools config not found, run: dot-files --dev-tools init" >&2
                    return 1
                end

                set -l current_val (grep "^$tool_name\s*=" "$devtools_file" 2>/dev/null | tail -n 1 | string trim | string replace -r '.*=\s*' '' | string trim -c ',"')
                if test -z "$current_val"
                    echo "dot-files: unknown tool '$tool_name'" >&2
                    echo "Tools: nodejs deno bun go rustc java npm pnpm yarn cargo pipx uv python git gh docker compose kubectl" >&2
                    return 1
                end

                set -l new_val
                if test "$current_val" = "true"
                    set new_val "false"
                else
                    set new_val "true"
                end

                sed -i "s/^$tool_name\s*=\s*.*/$tool_name = $new_val/" "$devtools_file"
                echo "dot-files: $tool_name -> $new_val"
                return 0
            end

            echo "dot-files: unknown dev-tools action '$dt_action'" >&2
            echo "Use: init, toggle" >&2
            return 1

        case '*'
            echo "dot-files: unknown option '$argv[1]'" >&2
            echo "Run 'dot-files' to see usage."
            return 1
    end
end
