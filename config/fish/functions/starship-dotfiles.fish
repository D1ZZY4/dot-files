# Manage dotfiles preferences: Starship style/color, Fastfetch welcome, dev-tools, and modules.
#
# Preference files (installed under ~/.config/starship/):
#   style      — separator style 1-5
#   color      — moonlight | catppuccin-macchiato
#   username   — Fastfetch welcome name (empty = system username)
#   dev-tools  — TOML file controlling which dev tools are shown
#   modules    — newline-separated list of enabled module filenames (without .toml)

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

    set -l enabled_modules (__dotfiles_get_enabled_modules "$modules_file")

    echo "$heading""Usage$normal"
    echo "  starship-dotfiles --style 1|2|3|4|5"
    echo "  starship-dotfiles --color moonlight|catppuccin-macchiato"
    echo "  starship-dotfiles --username NAME"
    echo "  starship-dotfiles --username reset"
    echo "  starship-dotfiles --enable-module core|directory|git|languages|package|file-icons"
    echo "  starship-dotfiles --disable-module core|directory|git|languages|package|file-icons"
    echo "  starship-dotfiles --list-modules"
    echo "  starship-dotfiles --dev-tools init"
    echo "  starship-dotfiles --dev-tools toggle <tool>"
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

function __dotfiles_get_enabled_modules --argument-names modules_file
    set -l enabled
    if test -f "$modules_file"
        for line in (cat "$modules_file")
            set -l trimmed (string trim -- $line)
            if test -z "$trimmed"
                continue
            end
            if string match -qr '^\s*#' -- "$trimmed"
                continue
            end
            set -a enabled "$trimmed"
        end
    end
    echo $enabled
end

function __dotfiles_module_enabled --argument-names module_name modules_file
    set -l enabled (__dotfiles_get_enabled_modules "$modules_file")
    for m in $enabled
        if test "$m" = "$module_name"
            return 0
        end
    end
    return 1
end

function __dotfiles_write_modules_file --argument-names modules_file
    set -l all_modules core directory git languages package file-icons
    set -l current_enabled (__dotfiles_get_enabled_modules "$modules_file")

    if test (count $current_enabled) -eq 0
        for idx in (seq (count $all_modules))
            set -l m $all_modules[$idx]
            if test "$m" = file-icons
                echo "# $m"
            else
                echo "$m"
            end
        end > "$modules_file"
        return
    end

    for m in $all_modules
        set -l found false
        for e in $current_enabled
            if test "$e" = "$m"
                set found true
                break
            end
        end
        if test "$found" = true
            echo "$m"
        else
            echo "# $m"
        end
    end > "$modules_file.new"
    mv "$modules_file.new" "$modules_file"
end

function starship-dotfiles --description 'Manage Starship and Fastfetch dotfiles preferences'
    set -l starship_dir "$HOME/.config/starship"
    set -l style_file "$starship_dir/style"
    set -l color_file "$starship_dir/color"
    set -l username_file "$starship_dir/username"
    set -l modules_file "$starship_dir/modules"
    set -l devtools_file "$starship_dir/dev-tools.toml"

    if test (count $argv) -eq 0
        __dotfiles_show_catalog "$style_file" "$color_file" "$username_file" "$modules_file"
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

        case --enable-module
            if test (count $argv) -lt 2
                echo "starship-dotfiles: missing module name" >&2
                echo "Available: core directory git languages package file-icons" >&2
                return 1
            end

            set -l module_name $argv[2]
            set -l all_modules core directory git languages package file-icons
            set -l valid false
            for m in $all_modules
                if test "$m" = "$module_name"
                    set valid true
                    break
                end
            end

            if test "$valid" = false
                echo "starship-dotfiles: unknown module '$module_name'" >&2
                echo "Available: core directory git languages package file-icons" >&2
                return 1
            end

            set -l current (__dotfiles_get_enabled_modules "$modules_file")
            set -l found_mod false
            for e in $current
                if test "$e" = "$module_name"
                    set found_mod true
                    break
                end
            end

            if test "$found_mod" = true
                echo "starship-dotfiles: module '$module_name' is already enabled"
            else
                if test -f "$modules_file"
                    sed -i "s/^# $module_name\$/$module_name/" "$modules_file" 2>/dev/null || \
                    echo "$module_name" >> "$modules_file"
                else
                    echo "$module_name" > "$modules_file"
                end
                echo "starship-dotfiles: module '$module_name' enabled"
            end
            starship-rebuild
            echo ""
            __dotfiles_starship_prompt_block

        case --disable-module
            if test (count $argv) -lt 2
                echo "starship-dotfiles: missing module name" >&2
                echo "Available: core directory git languages package file-icons" >&2
                return 1
            end

            set -l module_name $argv[2]
            set -l all_modules core directory git languages package file-icons
            set -l valid false
            for m in $all_modules
                if test "$m" = "$module_name"
                    set valid true
                    break
                end
            end

            if test "$valid" = false
                echo "starship-dotfiles: unknown module '$module_name'" >&2
                echo "Available: core directory git languages package file-icons" >&2
                return 1
            end

            if test "$module_name" = core
                echo "starship-dotfiles: cannot disable 'core' module (required)" >&2
                return 1
            end

            if test -f "$modules_file"
                sed -i "s/^$module_name\$/# $module_name/" "$modules_file" 2>/dev/null || true
            end
            echo "starship-dotfiles: module '$module_name' disabled"
            starship-rebuild
            echo ""
            __dotfiles_starship_prompt_block

        case --list-modules
            echo "Available modules (core cannot be disabled):"
            for m in core directory git languages package file-icons
                if test "$m" = core
                    echo "  (required) $m"
                else
                    if __dotfiles_module_enabled "$m" "$modules_file"
                        echo "  (enabled)  $m"
                    else
                        echo "  (disabled) $m"
                    end
                end
            end
            echo ""
            echo "Use --enable-module or --disable-module to toggle."

        case --dev-tools
            if test (count $argv) -lt 2
                echo "starship-dotfiles: missing dev-tools action" >&2
                echo "Usage: starship-dotfiles --dev-tools init" >&2
                echo "       starship-dotfiles --dev-tools toggle <tool_name>" >&2
                return 1
            end

            set -l dt_action $argv[2]

            if test "$dt_action" = init
                if not test -f "$devtools_file"
                    printf '%s\n' \
                        '# Dev tools visibility configuration.' \
                        '# Set enabled = false to hide a tool or entire section.' \
                        '# Individual tool settings override section settings.' \
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
                        'enabled = true' \
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
                    echo "starship-dotfiles: dev-tools config created at $devtools_file"
                else
                    echo "starship-dotfiles: dev-tools config already exists at $devtools_file"
                end
                return 0
            end

            if test "$dt_action" = toggle
                if test (count $argv) -lt 3
                    echo "starship-dotfiles: missing tool name for toggle" >&2
                    echo "Tools: nodejs deno bun go rustc java npm pnpm yarn cargo pipx uv git gh docker compose kubectl" >&2
                    return 1
                end

                set -l tool_name $argv[3]
                if not test -f "$devtools_file"
                    echo "starship-dotfiles: dev-tools config not found, run: starship-dotfiles --dev-tools init" >&2
                    return 1
                end

                set -l current_val (grep "^$tool_name\s*=" "$devtools_file" 2>/dev/null | tail -n 1 | string trim | string replace -r '.*=\s*' '' | string trim -c ',"')
                if test -z "$current_val"
                    echo "starship-dotfiles: unknown tool '$tool_name'" >&2
                    echo "Tools: nodejs deno bun go rustc java npm pnpm yarn cargo pipx uv git gh docker compose kubectl" >&2
                    return 1
                end

                set -l new_val
                if test "$current_val" = "true"
                    set new_val "false"
                else
                    set new_val "true"
                end

                sed -i "s/^$tool_name\s*=\s*.*/$tool_name = $new_val/" "$devtools_file"
                echo "starship-dotfiles: $tool_name -> $new_val"
                return 0
            end

            echo "starship-dotfiles: unknown dev-tools action '$dt_action'" >&2
            echo "Use: init, toggle" >&2
            return 1

        case '*'
            echo "starship-dotfiles: unknown option '$argv[1]'" >&2
            echo "Run 'starship-dotfiles' to see usage."
            return 1
    end
end
