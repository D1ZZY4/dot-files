#!/usr/bin/env fish
# Dev Tools startup block: lists installed runtimes, package managers, Python, and CLI tools.
# Invoked from ~/.config/fish/conf.d/zz-fastfetch.fish after Fastfetch.
# Individual tools can be toggled via: dot-files --dev-tools toggle <tool>

# Global so the function below can see it (Fish functions do not inherit script locals).
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

function __command_version
    set -l command_name $argv[1]
    set -l version_command $argv[2]
    if not type -q $command_name
        return
    end
    set -l value (eval $version_command 2>/dev/null | string collect)
    if test -n "$value"
        echo $value
    else
        echo "available"
    end
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
        echo "  $icon $padded_label $tool_version"
    end
end

function __python_version_from_binary
    if test -x "$argv[1]"
        set -l py_version_value ($argv[1] --version 2>/dev/null | string replace 'Python ' 'v')
        if test -n "$py_version_value"
            echo $py_version_value
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

set -l muted (set_color brblack)
set -l title (set_color magenta)
set -l runtime_color (set_color blue)
set -l package_color (set_color cyan)
set -l python_color (set_color yellow)
set -l system_color (set_color green)
set -l infra_color (set_color brblue)
set -l normal (set_color normal)

# Build version lines based on enabled tools
set -l runtime_lines
set -l package_lines
set -l python_lines
set -l system_lines
set -l infra_lines

if __dt_enabled nodejs
    set -a runtime_lines (__tool_line "" "nodejs" (__command_version node 'node --version'))
end
if __dt_enabled deno
    set -a runtime_lines (__tool_line "" "deno" (__command_version deno 'deno --version | head -n 1 | command sed -E "s/^deno ([^ ]+).*/v\\1/"'))
end
if __dt_enabled bun
    set -a runtime_lines (__tool_line "" "bun" (__command_version bun 'bun --version | string replace -r "^" "v"'))
end
if __dt_enabled go
    set -a runtime_lines (__tool_line "" "go" (__command_version go 'go version | command sed -E "s/.*go([0-9.]+).*/v\\1/"'))
end
if __dt_enabled rustc
    set -a runtime_lines (__tool_line "" "rustc" (__command_version rustc 'rustc --version | command sed -E "s/rustc ([0-9.]+).*/v\\1/"'))
end
if __dt_enabled java
    set -a runtime_lines (__tool_line "" "java" (__command_version java 'java --version | head -n 1 | command sed -E "s/^[^0-9]*([0-9][^ ]*).*/v\\1/"'))
end

if __dt_enabled npm
    set -a package_lines (__tool_line "" "npm" (__command_version npm 'npm --version | string replace -r "^" "v"'))
end
if __dt_enabled pnpm
    set -a package_lines (__tool_line "" "pnpm" (__command_version pnpm 'pnpm --version | string replace -r "^" "v"'))
end
if __dt_enabled yarn
    set -a package_lines (__tool_line "" "yarn" (__command_version yarn 'yarn --version | string replace -r "^" "v"'))
end
if __dt_enabled cargo
    set -a package_lines (__tool_line "" "cargo" (__command_version cargo 'cargo --version | command sed -E "s/cargo ([0-9.]+).*/v\\1/"'))
end
if __dt_enabled pipx
    set -a package_lines (__tool_line "󰆦" "pipx" (__command_version pipx 'pipx --version | string replace -r "^" "v"'))
end
if __dt_enabled uv
    set -a package_lines (__tool_line "󰔛" "uv" (__command_version uv 'uv --version | command sed -E "s/^uv ([^ ]+).*/v\\1/"'))
end

if __dt_enabled python
    set -a python_lines (__python_lines)
end

if __dt_enabled git
    set -a system_lines (__tool_line "" "git" (__command_version git 'git --version | string replace "git version " "v"'))
end
if __dt_enabled gh
    set -a system_lines (__tool_line "" "gh" (__command_version gh 'gh --version | head -n 1 | command sed -E "s/gh version ([0-9.]+).*/v\\1/"'))
end

if __dt_enabled docker
    set -a infra_lines (__tool_line "" "docker" (__command_version docker 'docker --version | command sed -E "s/Docker version ([^,]+).*/v\\1/"'))
end
if __dt_enabled compose
    set -a infra_lines (__tool_line "" "compose" (__command_version docker 'docker compose version 2>/dev/null | command sed -E "s/.*v?([0-9.]+).*/v\\1/"'))
end
if __dt_enabled kubectl
    set -a infra_lines (__tool_line "󱃾" "kubectl" (__command_version kubectl 'kubectl version --client=true 2>/dev/null | head -n 1 | command sed -E "s/.*v([0-9.]+).*/v\\1/"'))
end

set -l total_lines (math (count $runtime_lines) + (count $package_lines) + (count $python_lines) + (count $system_lines) + (count $infra_lines))

if test $total_lines -eq 0
    exit 0
end

echo "$muted────────────────────────────────────────────────────────────$normal"
echo "$title"Dev Tools"$normal"
echo "$muted────────────────────────────────────────────────────────────$normal"
__print_section "$runtime_color" "Runtimes" $runtime_lines
__print_section "$package_color" "Package managers" $package_lines
__print_section "$python_color" "Python" $python_lines
__print_section "$system_color" "System tools" $system_lines
__print_section "$infra_color" "Infrastructure" $infra_lines
