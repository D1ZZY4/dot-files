#!/usr/bin/env fish
# Dev Tools startup block: lists installed runtimes, package managers, Python, and CLI tools.
# Invoked from ~/.config/fish/conf.d/zz-fastfetch.fish after Fastfetch.
# Individual tools can be toggled via: dot-files --dev-tools toggle <tool>

# Global so the functions below can see it (Fish functions do not inherit script locals).
set -g __dt_config_file "$HOME/.config/starship/dev-tools.toml"

# A tool is enabled unless dev-tools.toml explicitly sets `<tool> = false`.
function __dt_enabled
    set -l tool $argv[1]
    if test -z "$tool"
        return 1
    end
    if test -f "$__dt_config_file"; and grep -q "^$tool\s*=\s*false" "$__dt_config_file" 2>/dev/null
        return 1
    end
    return 0
end

function __pad_label
    set -l label $argv[1]
    set -l width $argv[2]
    set -l length (string length -- "$label")
    if test $length -ge $width
        echo -n "$label"
        return
    end
    echo -n "$label"(string repeat -n (math $width - $length) ' ')
end

function __tool_line
    set -l icon $argv[1]
    set -l label $argv[2]
    set -l tool_version $argv[3]
    if test -n "$tool_version"
        set -l padded_label (__pad_label "$label" 10)
        echo "  $icon  $padded_label  $tool_version"
    end
end

function __python_version_from_binary
    if test -x "$argv[1]"
        set -l py_version_value (command $argv[1] --version 2>/dev/null | string replace 'Python ' 'v')
        if test -n "$py_version_value"
            echo "$py_version_value"
        end
    end
end

function __python_minor_from_binary
    set -l name (basename "$argv[1]")
    string replace -r '^python' '' -- "$name"
end

function __collect_python_binaries
    set -l seen
    for path_dir in (string split : -- $PATH)
        if test -d "$path_dir"
            for binary in (command find "$path_dir" -maxdepth 1 -name 'python3.[0-9]*' 2>/dev/null)
                set -l binary_name (basename "$binary")
                if not string match -qr '^python3\.[0-9]+$' -- "$binary_name"
                    continue
                end
                if test -x "$binary"; and not contains -- "$binary" $seen
                    set -a seen "$binary"
                    echo "$binary"
                end
            end
        end
    end
end

function __python_lines
    set -l rows
    for binary in (__collect_python_binaries)
        set -l minor (__python_minor_from_binary "$binary")
        set -l py_version_value (__python_version_from_binary "$binary")
        if test -n "$minor"; and test -n "$py_version_value"
            set -a rows "$minor - $py_version_value"
        end
    end
    set rows (string join \n $rows | sort -V | uniq)
    if test (count $rows) -eq 0
        return
    end
    echo "   python"
    set -l total (count $rows)
    for index in (seq 1 $total)
        set -l branch "├─"
        if test $index -eq $total
            set branch "└─"
        end
        echo "    $branch $rows[$index]"
    end
end

function __print_section
    set -l section_color $argv[1]
    set -l section_title $argv[2]
    set -l lines $argv[3..-1]
    if test (count $lines) -eq 0
        return
    end
    echo $section_color$section_title(set_color normal)
    for line in $lines
        echo $line
    end
end

# Render the Dev Tools block. Extracted so __dt_reload can re-render without
# re-sourcing the entire file (which would try to auto-render again).
function __dt_render
    set -l muted (set_color brblack)
    set -l title (set_color magenta)
    set -l runtime_color (set_color blue)
    set -l package_color (set_color cyan)
    set -l python_color (set_color yellow)
    set -l system_color (set_color green)
    set -l infra_color (set_color brblue)
    set -l normal (set_color normal)

    # Build version lines based on enabled tools. Each tool is a direct Fish
    # pipeline — the tool's own --version piped through Fish builtins.
    # No eval, no bash -c.
    set -l runtime_lines
    set -l package_lines
    set -l python_lines
    set -l system_lines
    set -l infra_lines

    if __dt_enabled nodejs
        if type -q node
            set -a runtime_lines (__tool_line "" "nodejs" \
                (node --version 2>/dev/null | string replace '^' 'v' | string collect))
        end
    end
    if __dt_enabled deno
        if type -q deno
            set -a runtime_lines (__tool_line "" "deno" \
                (deno --version 2>/dev/null | string replace -r '^deno ([^ ]+).*' 'v\1' | string collect))
        end
    end
    if __dt_enabled bun
        if type -q bun
            set -a runtime_lines (__tool_line "" "bun" \
                (bun --version 2>/dev/null | string replace '^' 'v' | string collect))
        end
    end
    if __dt_enabled go
        if type -q go
            set -a runtime_lines (__tool_line "" "go" \
                (go version 2>/dev/null | string replace -r '.*go([0-9.]+).*' 'v\1' | string collect))
        end
    end
    if __dt_enabled rustc
        if type -q rustc
            set -a runtime_lines (__tool_line "" "rustc" \
                (rustc --version 2>/dev/null | string replace -r 'rustc ([0-9.]+).*' 'v\1' | string collect))
        end
    end
    if __dt_enabled java
        if type -q java
            set -a runtime_lines (__tool_line "" "java" \
                (java --version 2>/dev/null | string replace -r '^[^0-9]*([0-9][^ ]*).*' 'v\1' | string collect))
        end
    end

    if __dt_enabled npm
        if type -q npm
            set -a package_lines (__tool_line "" "npm" \
                (npm --version 2>/dev/null | string replace '^' 'v' | string collect))
        end
    end
    if __dt_enabled pnpm
        if type -q pnpm
            set -a package_lines (__tool_line "" "pnpm" \
                (pnpm --version 2>/dev/null | string replace '^' 'v' | string collect))
        end
    end
    if __dt_enabled yarn
        if type -q yarn
            set -a package_lines (__tool_line "" "yarn" \
                (yarn --version 2>/dev/null | string replace '^' 'v' | string collect))
        end
    end
    if __dt_enabled cargo
        if type -q cargo
            set -a package_lines (__tool_line "" "cargo" \
                (cargo --version 2>/dev/null | string replace -r 'cargo ([0-9.]+).*' 'v\1' | string collect))
        end
    end
    if __dt_enabled pipx
        if type -q pipx
            set -a package_lines (__tool_line "󰆦" "pipx" \
                (pipx --version 2>/dev/null | string replace '^' 'v' | string collect))
        end
    end
    if __dt_enabled uv
        if type -q uv
            set -a package_lines (__tool_line "󰔛" "uv" \
                (uv --version 2>/dev/null | string replace -r '^uv ([^ ]+).*' 'v\1' | string collect))
        end
    end

    if __dt_enabled python
        set -a python_lines (__python_lines)
    end

    if __dt_enabled git
        if type -q git
            set -a system_lines (__tool_line "" "git" \
                (git --version 2>/dev/null | string replace 'git version ' 'v' | string collect))
        end
    end
    if __dt_enabled gh
        if type -q gh
            set -a system_lines (__tool_line "" "gh" \
                (gh --version 2>/dev/null | string replace -r 'gh version ([0-9.]+).*' 'v\1' | string collect))
        end
    end

    if __dt_enabled docker
        if type -q docker
            set -a infra_lines (__tool_line "" "docker" \
                (docker --version 2>/dev/null | string replace -r 'Docker version ([^,]+).*' 'v\1' | string collect))
        end
    end
    if __dt_enabled compose
        if type -q docker
            set -a infra_lines (__tool_line "" "compose" \
                (docker compose version 2>/dev/null | string replace -r '.*v?([0-9.]+).*' 'v\1' | string collect))
        end
    end
    if __dt_enabled kubectl
        if type -q kubectl
            set -a infra_lines (__tool_line "󱃾" "kubectl" \
                (kubectl version --client=true 2>/dev/null | string replace -r '.*v([0-9.]+).*' 'v\1' | string collect))
        end
    end

    set -l total_lines (math (count $runtime_lines) + (count $package_lines) + (count $python_lines) + (count $system_lines) + (count $infra_lines))

    if test $total_lines -eq 0
        return 0
    end

    echo "$muted────────────────────────────────────────────────────────────$normal"
    echo "$title"Dev Tools"$normal"
    echo "$muted────────────────────────────────────────────────────────────$normal"
    __print_section "$runtime_color" "Runtimes" $runtime_lines
    __print_section "$package_color" "Package managers" $package_lines
    __print_section "$python_color" "Python" $python_lines
    __print_section "$system_color" "System tools" $system_lines
    __print_section "$infra_color" "Infrastructure" $infra_lines
end

# Re-render the Dev Tools block from the current session. Tracks the
# dev-tools.toml mtime in a universal variable so it only re-renders when
# the file actually changed. Designed to be called from
# `dot-files --dev-tools reload` after sourcing this file.
function __dt_reload
    set -l devtools_file "$HOME/.config/starship/dev-tools.toml"
    if not test -f "$devtools_file"
        echo "dot-files: dev-tools config not found, run: dot-files --dev-tools init" >&2
        return 1
    end

    # Track config file mtime; only re-render when the file changed.
    set -q __dt_config_file_mtime; or set -U __dt_config_file_mtime 0
    set -l current_mtime
    if command -v stat >/dev/null 2>&1
        # GNU stat (-c) vs BSD/macOS stat (-f). Both return epoch seconds.
        stat -c '%Y' "$devtools_file" 2>/dev/null
        or stat -f '%m' "$devtools_file" 2>/dev/null
    end

    # Security invariant: all version_command strings in __dt_render are hardcoded
    # literals. They must never be derived from user input — they are piped through
    # Fish builtins (string replace), not eval or bash -c, so injection is not
    # possible as long as this invariant holds.

    if test -z "$current_mtime"
        # OS without GNU stat — just render.
        __dt_render
        echo "Dev Tools reloaded."
        return 0
    end

    if test "$current_mtime" = "$__dt_config_file_mtime"
        echo "Dev Tools reloaded (no changes detected)."
        return 0
    end

    __dt_render
    set -U __dt_config_file_mtime "$current_mtime"
    echo "Dev Tools reloaded."
end

# Auto-render when this script is invoked directly (e.g., from zz-fastfetch.fish).
# Skip when sourced for function definitions (reload helper passes this flag).
if not set -q __dt_force_no_auto_render
    __dt_render
end
