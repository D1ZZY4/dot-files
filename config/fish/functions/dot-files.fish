# Manage dotfiles preferences: Starship style/color, Fastfetch welcome, dev-tools, and modules.
#
# Preference files (installed under ~/.config/starship/):
#   style      — separator style 1-5
#   color      — moonlight | catppuccin-macchiato | catppuccin-mocha
#   username   — Fastfetch welcome name (empty = system username)
#   dev-tools.toml — controls which dev tools are shown
#   modules.conf   — one module name per line; a leading # disables that module

function __dotfiles_all_modules
    printf '%s\n' core directory git languages package file-icons
end

# Escape regex metacharacters for safe literal sed matching.
function __dotfiles_regex_escape
    set -l s $argv[1]
    # Escape each BRE metacharacter. Replacement strings use double-backslash
    # because string replace -a interprets \X as a special escape; \\ → \ literal.
    string replace -a '\\' '\\' -- "$s" \
        | string replace -a '/' '\\/' \
        | string replace -a '.' '\\.' \
        | string replace -a '^' '\\^' \
        | string replace -a '$' '\\$' \
        | string replace -a '*' '\\*' \
        | string replace -a '+' '\\+' \
        | string replace -a '?' '\\?' \
        | string replace -a '[' '\\[' \
        | string replace -a ']' '\\]' \
        | string replace -a '(' '\\(' \
        | string replace -a ')' '\\)' \
        | string replace -a '{' '\\{' \
        | string replace -a '}' '\\}' \
        | string replace -a '|' '\\|' \
        | string replace -a '&' '\\&'
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
        "$style" > "$path"
end

function __dotfiles_write_color_file --argument-names color path
    printf '%s\n' \
        '# Starship color palette name. Must match colors/<name>.toml' \
        '# Options: moonlight | catppuccin-macchiato | catppuccin-mocha' \
        "$color" > "$path"
end

function __dotfiles_rebuild_quiet
    if not type -q starship
        return 0
    end
    fish "$build_fish" >/dev/null 2>&1
end

function __dotfiles_starship_prompt_block
    set -l config "$HOME/.config/starship.toml"
    set -l term $TERM
    if test -z "$term"; or test "$term" = dumb
        set term xterm-256color
    end

    set -l lines (
        env TERM="$term" STARSHIP_CONFIG="$config" starship prompt --terminal-width 200 2>/dev/null \
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

# Open a preference file in the user's preferred editor.
# The `-f` existence guard is a safety net — each public caller already verifies
# the file exists before invoking this helper (via the style, color, modules,
# username, or dev-tools branches).
function __dotfiles_edit_file --argument-names file_path
    if not test -f "$file_path"
        echo "dot-files: $file_path does not exist" >&2
        return 1
    end
    echo "dot-files: editing $file_path"
    if set -q EDITOR
        if test -n "$EDITOR"
            "$EDITOR" "$file_path"
        else
            echo "dot-files: EDITOR is set but empty" >&2
            return 1
        end
    else if type -q nvim
        nvim "$file_path"
    else if type -q vim
        vim "$file_path"
    else if type -q nano
        nano "$file_path"
    else
        echo "dot-files: no editor found (set EDITOR)" >&2
        return 1
    end
end

# Locate the dotfiles installation repo. Checks the curl-installed path
# ($HOME/.local/share/dotfiles) and the DOTFILES_DIR env override. Returns
# the repo path on stdout, empty string if not found.
function __dotfiles_repo_path
    set -l curl_path "$HOME/.local/share/dotfiles"
    if test -d "$curl_path"; and git -C "$curl_path" rev-parse --is-inside-work-tree >/dev/null 2>&1
        echo "$curl_path"
        return 0
    end
    if set -q DOTFILES_DIR
        if test -d "$DOTFILES_DIR"; and git -C "$DOTFILES_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1
            echo "$DOTFILES_DIR"
            return 0
        end
    end
    return 1
end

# Report the git status of the installed dotfiles repo.
function __dotfiles_status
    # set does not propagate the exit status of command substitution, so check
    # $repo directly instead of $status.
    set -l repo (__dotfiles_repo_path)
    if test -z "$repo"
        echo "Installed via copy or unknown source. Cannot determine status."
        return 0
    end

    set -l dirty 0
    set -l branch_info (git -C "$repo" symbolic-ref --short HEAD 2>/dev/null; or echo "detached")
    echo "Repo: $repo"
    echo "Branch: $branch_info"

    # Modified files
    set -l modified (git -C "$repo" diff --name-only 2>/dev/null)
    if test (count $modified) -gt 0
        echo "Modified files:"
        for f in $modified
            echo "  M $f"
        end
        set dirty 1
    else
        echo "No modified files."
    end

    # Untracked files under config/
    set -l untracked (git -C "$repo" ls-files --others --exclude-standard config/ 2>/dev/null)
    if test (count $untracked) -gt 0
        echo "Untracked files under config/:"
        for f in $untracked
            echo "  ? $f"
        end
        set dirty 1
    end

    # Ahead / behind vs upstream
    set -l ahead (git -C "$repo" rev-list --count "@{upstream}..HEAD" 2>/dev/null; or echo 0)
    set -l behind (git -C "$repo" rev-list --count "HEAD..@{upstream}" 2>/dev/null; or echo 0)
    if test "$ahead" -gt 0; or test "$behind" -gt 0
        echo "Ahead $ahead, behind $behind."
        set dirty 1
    else
        echo "Installed dotfiles are up to date."
    end

    # Exit 1 when dirty or behind so scripts/CI can detect drift.
    return $dirty
end

# Canonical dev-tools tool list — single source of truth for init template,
# toggle error messages, and completions. Edit this; don't duplicate it.
function __dotfiles_devtools_list
    printf '%s\n' nodejs deno bun go rustc java npm pnpm yarn cargo pipx uv python git gh docker compose kubectl
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
    echo "  dot-files --color moonlight|catppuccin-macchiato|catppuccin-mocha"
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
        set -lx STARSHIP_STYLE_PREVIEW $style_check
        set -lx STARSHIP_COLOR_PREVIEW $saved_color
        __dotfiles_rebuild_quiet
        set -l marker (__dotfiles_active_marker $style_check $saved_style)
        __dotfiles_print_prompt_preview "$marker$style_check"
    end

    echo ""
    echo "$heading""Colors$normal $muted(style 5 · real prompt · * = active)$normal"

    for color_check in moonlight catppuccin-macchiato catppuccin-mocha
        set -lx STARSHIP_STYLE_PREVIEW 5
        set -lx STARSHIP_COLOR_PREVIEW $color_check
        __dotfiles_rebuild_quiet
        set -l marker (__dotfiles_active_marker $color_check $saved_color)
        __dotfiles_print_prompt_preview "$marker$color_check"
    end

    # Live files were never touched; one final rebuild restores the on-disk
    # starship.toml to match the saved preferences.
    set -e STARSHIP_STYLE_PREVIEW
    set -e STARSHIP_COLOR_PREVIEW
    __dotfiles_rebuild_quiet

    echo ""
    echo "$heading""Fastfetch welcome$normal"
    set -l yellow (set_color yellow)
    echo "  $muted(system)$normal  Welcome, $yellow"{user-name}"$normal!"
    echo "  $muted(custom)$normal   Welcome, "$yellow"Alex"$normal"!"
end

# Read-only diagnostics. Does not write to any file.
function __dotfiles_doctor
    set -l starship_dir "$HOME/.config/starship"
    set -l color_file "$starship_dir/color"
    set -l modules_file "$starship_dir/modules.conf"
    set -l devtools_file "$starship_dir/dev-tools.toml"
    set -l colors_dir "$starship_dir/colors"
    set -l has_fail 0

    echo "dot-files doctor:"

    # 1. starship on PATH
    if type -q starship
        echo "[OK] starship is on PATH"
    else
        echo "[FAIL] starship is not on PATH" >&2
        set has_fail 1
    end

    # 2. fastfetch on PATH
    if type -q fastfetch
        echo "[OK] fastfetch is on PATH"
    else
        echo "[FAIL] fastfetch is not on PATH" >&2
        set has_fail 1
    end

    # 3. fish config loads cleanly
    if fish -c 'source $HOME/.config/fish/config.fish' >/dev/null 2>&1
        echo "[OK] fish config loads cleanly"
    else
        echo "[FAIL] fish config fails to load" >&2
        set has_fail 1
    end

    # 4. color value matches a known theme file
    set -l color_val (dotfiles-read-setting "$color_file"; or echo moonlight)
    set -l color_theme_file "$colors_dir/$color_val.toml"
    if not test -f "$color_theme_file"
        echo "[WARN] color '$color_val' does not match any theme in colors/" >&2
    else
        echo "[OK] color '$color_val' matches a known theme"
    end

    # 5. modules.conf references only known modules
    set -l unknown_modules
    if test -f "$modules_file"
        for mod in (dotfiles-read-modules "$modules_file" 2>/dev/null)
            if not contains -- "$mod" (__dotfiles_all_modules)
                set -a unknown_modules "$mod"
            end
        end
    end
    if test (count $unknown_modules) -eq 0
        echo "[OK] modules.conf references only known modules"
    else
        echo "[WARN] modules.conf contains unknown modules: "(string join ' ' $unknown_modules) >&2
    end

    # 6. dev-tools.toml keys match known tools
    set -l unknown_tools
    if test -f "$devtools_file"
        set -l in_section 0
        while read -l line
            set -l trimmed (string trim -- "$line")
            if test -z "$trimmed"
                continue
            end
            if string match -qr '^#' -- "$trimmed"
                continue
            end
            if string match -qr '^\[' -- "$trimmed"
                set in_section 1
                continue
            end
            if test $in_section -eq 1
                if string match -qr '=' -- "$trimmed"
                    set -l key (string trim (string split -m 1 = -- "$trimmed")[1])
                    if string match -qr '^[a-z_]+$' -- "$key"
                        if not contains -- "$key" (__dotfiles_devtools_list)
                            set -a unknown_tools "$key"
                        end
                    end
                end
            end
        end < "$devtools_file"
    end
    if test (count $unknown_tools) -eq 0
        echo "[OK] dev-tools.toml keys match known tools"
    else
        echo "[WARN] dev-tools.toml contains unknown keys: "(string join ' ' $unknown_tools) >&2
    end

    # 7. starship.toml exists (symlink or regular file)
    if test -e "$starship_dir/starship.toml"
        echo "[OK] starship.toml exists"
    else
        echo "[FAIL] starship.toml not found at $starship_dir/starship.toml" >&2
        set has_fail 1
    end

    # 8. fastfetch config.jsonc exists
    if test -f "$HOME/.config/fastfetch/config.jsonc"
        echo "[OK] fastfetch config.jsonc exists"
    else
        echo "[FAIL] fastfetch config.jsonc not found at $HOME/.config/fastfetch/config.jsonc" >&2
        set has_fail 1
    end

    return $has_fail
end

function dot-files --description 'Manage Starship and Fastfetch dotfiles preferences'
    set -l starship_dir "$HOME/.config/starship"
    set -l build_fish "$starship_dir/build.fish"
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
            return 0

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
            if test "$username" = reset -o "$username" = system -o "$username" = default
                __dotfiles_username_template > "$username_file"
                fastfetch-apply-welcome
                and echo "dot-files: welcome reset to system username ($username_file)"
                return 0
            end

            __dotfiles_username_template > "$username_file"
            echo "$username" >> "$username_file"
            fastfetch-apply-welcome
            and echo "Fastfetch welcome set to: Welcome, $username!"
            and echo "Saved in $username_file"

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
                echo "       dot-files --dev-tools reload" >&2
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
                    set -l tools_list (string join ' ' (__dotfiles_devtools_list))
                    echo "Tools: $tools_list" >&2
                    return 1
                end

                set -l tool_name $argv[3]
                if not test -f "$devtools_file"
                    echo "dot-files: dev-tools config not found, run: dot-files --dev-tools init" >&2
                    return 1
                end

                # [[:space:]]* ensures the tool name is followed by =, not another
                # character like 'x' (e.g., 'npm' does not match 'npmx = true').
                set -l current_val (grep -E "^$tool_name[[:space:]]*=" "$devtools_file" 2>/dev/null | tail -n 1 | string trim | string replace -r '.*=\s*' '' | string trim -c ',"')
                if test -z "$current_val"
                    echo "dot-files: unknown tool '$tool_name'" >&2
                    set -l tools_list (string join ' ' (__dotfiles_devtools_list))
                    echo "Tools: $tools_list" >&2
                    return 1
                end

                set -l new_val
                if test "$current_val" = "true"
                    set new_val "false"
                else
                    set new_val "true"
                end

                set -l escaped (__dotfiles_regex_escape "$tool_name")
                # sed -i.bak is portable across GNU and BSD/macOS sed.
                sed -i.bak "s/^$escaped[[:space:]]*=[[:space:]]*.*/$tool_name = $new_val/" "$devtools_file"
                rm -f "$devtools_file.bak"
                echo "dot-files: $tool_name -> $new_val"
                return 0
            end

            if test "$dt_action" = reload
                if not test -f "$devtools_file"
                    echo "dot-files: dev-tools config not found, run: dot-files --dev-tools init" >&2
                    return 1
                end
                # Source dev-tools.fish with the auto-render guard so __dt_reload
                # becomes available without re-rendering on source.
                set -x __dt_force_no_auto_render 1
                source "$HOME/.config/fastfetch/dev-tools.fish"
                set -e __dt_force_no_auto_render
                if functions -q __dt_reload
                    __dt_reload
                    return 0
                else
                    echo "dot-files: __dt_reload not found in dev-tools.fish" >&2
                    return 1
                end
            end

            echo "dot-files: unknown dev-tools action '$dt_action'" >&2
            echo "Use: init, toggle, reload" >&2
            return 1

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
                case dev-tools
                    __dotfiles_edit_file "$devtools_file"; or return 1
                    echo "dot-files: dev-tools updated (changes apply on next startup)"
                case '*'
                    echo "dot-files: unknown edit target '$edit_target'" >&2
                    echo "Usage: dot-files --edit style|color|modules|username|dev-tools" >&2
                    return 1
            end

        case '*'
            echo "dot-files: unknown option '$argv[1]'" >&2
            echo "Run 'dot-files' to see usage."
            return 1
    end
end
