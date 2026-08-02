#!/usr/bin/env fish
# Dev Tools: lists installed runtimes, package managers, Python, and CLI tools.
# Called from zz-fastfetch.fish after Fastfetch.

set -g __dt_config_file "$HOME/.config/starship/dev-tools.toml"

# Source helpers from dev-tools/ directory.
for f in (dirname (status --current-filename))/dev-tools/*.fish
    test -f "$f"; and source "$f"
end

function __dt_render
    set -l muted (set_color brblack)
    set -l title (set_color magenta)
    set -l runtime_color (set_color blue)
    set -l package_color (set_color cyan)
    set -l python_color (set_color yellow)
    set -l system_color (set_color green)
    set -l infra_color (set_color brblue)
    set -l normal (set_color normal)

    set -l runtime_lines
    set -l package_lines
    set -l python_lines
    set -l system_lines
    set -l infra_lines

    if __dt_enabled nodejs
        if type -q node
            set -a runtime_lines (__tool_line "" "nodejs" \
                (node --version 2>/dev/null | string collect))
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
                (bun --version 2>/dev/null | string replace -r '^' 'v' | string collect))
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
                (java --version 2>/dev/null | head -n1 | string replace -r '^[^0-9]*([0-9][^ ]*).*' 'v\1' | string collect))
        end
    end

    if __dt_enabled npm
        if type -q npm
            set -a package_lines (__tool_line "" "npm" \
                (npm --version 2>/dev/null | string replace -r '^' 'v' | string collect))
        end
    end
    if __dt_enabled pnpm
        if type -q pnpm
            set -a package_lines (__tool_line "" "pnpm" \
                (pnpm --version 2>/dev/null | string replace -r '^' 'v' | string collect))
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
        set -a python_lines (__dt_python_lines)
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
                (gh --version 2>/dev/null | string match -r 'gh version [0-9.]+' | string replace 'gh version ' 'v' | string collect))
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

# Auto-render on direct invocation. Skip when sourced for reload.
if not set -q __dt_force_no_auto_render
    __dt_render
end
