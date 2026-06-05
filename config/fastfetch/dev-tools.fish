#!/usr/bin/env fish
# Dev Tools startup block: lists installed runtimes, package managers, Python, and CLI tools.
# Invoked from ~/.config/fish/conf.d/zz-fastfetch.fish after Fastfetch.
# Add a tool: define a version variable below and append __tool_line to the right section.

function __command_version --argument-names command_name version_command
    # Return a version string for command_name, or nothing if the binary is missing.
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

function __pad_label --argument-names label width
    # Pad tool labels so version columns align (e.g. nodejs vs java).
    set -l length (string length -- "$label")
    if test $length -ge $width
        echo -n "$label"
        return
    end

    echo -n "$label"(string repeat -n (math $width - $length) ' ')
end

function __tool_line --argument-names icon label tool_version
    if test -n "$tool_version"; and test "$tool_version" != "not installed"
        set -l padded_label (__pad_label "$label" 10)
        echo "  $icon $padded_label $tool_version"
    end
end

function __python_version_from_binary --argument-names binary
    if test -x "$binary"
        set -l py_version_value ($binary --version 2>/dev/null | string replace 'Python ' 'v')
        if test -n "$py_version_value"
            echo $py_version_value
        end
    end
end

function __python_minor_from_binary --argument-names binary
    set -l name (basename "$binary")
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

function __print_section --argument-names section_color section_title
    # Print a colored section heading and its tool lines.
    set -l lines $argv[3..-1]

    if test (count $lines) -eq 0
        return
    end

    echo "$section_color$section_title$normal"
    for line in $lines
        if test -n "$line"
            echo "$line"
        end
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

set -l node_version (__command_version node 'node --version')
set -l deno_version (__command_version deno 'deno --version | head -n 1 | command sed -E "s/^deno ([^ ]+).*/v\\1/"')
set -l bun_version (__command_version bun 'bun --version | string replace -r "^" "v"')
set -l go_version (__command_version go 'go version | command sed -E "s/.*go([0-9.]+).*/v\\1/"')
set -l rust_version (__command_version rustc 'rustc --version | command sed -E "s/rustc ([0-9.]+).*/v\\1/"')
set -l java_version (__command_version java 'java --version | head -n 1 | command sed -E "s/^[^0-9]*([0-9][^ ]*).*/v\\1/"')

set -l npm_version (__command_version npm 'npm --version | string replace -r "^" "v"')
set -l pnpm_version (__command_version pnpm 'pnpm --version | string replace -r "^" "v"')
set -l yarn_version (__command_version yarn 'yarn --version | string replace -r "^" "v"')
set -l cargo_version (__command_version cargo 'cargo --version | command sed -E "s/cargo ([0-9.]+).*/v\\1/"')
set -l pipx_version (__command_version pipx 'pipx --version | string replace -r "^" "v"')
set -l uv_version (__command_version uv 'uv --version | command sed -E "s/^uv ([^ ]+).*/v\\1/"')

set -l git_version (__command_version git 'git --version | string replace "git version " "v"')
set -l gh_version (__command_version gh 'gh --version | head -n 1 | command sed -E "s/gh version ([0-9.]+).*/v\\1/"')

set -l docker_version (__command_version docker 'docker --version | command sed -E "s/Docker version ([^,]+).*/v\\1/"')
set -l compose_version (__command_version docker 'docker compose version 2>/dev/null | command sed -E "s/.*v?([0-9.]+).*/v\\1/"')
set -l kubectl_version (__command_version kubectl 'kubectl version --client=true 2>/dev/null | head -n 1 | command sed -E "s/.*v([0-9.]+).*/v\\1/"')

set -l runtime_lines \
    (__tool_line "" "nodejs" "$node_version") \
    (__tool_line "" "deno" "$deno_version") \
    (__tool_line "" "bun" "$bun_version") \
    (__tool_line "" "go" "$go_version") \
    (__tool_line "" "rustc" "$rust_version") \
    (__tool_line "" "java" "$java_version")

set -l package_lines \
    (__tool_line "" "npm" "$npm_version") \
    (__tool_line "" "pnpm" "$pnpm_version") \
    (__tool_line "" "yarn" "$yarn_version") \
    (__tool_line "" "cargo" "$cargo_version") \
    (__tool_line "󰆦" "pipx" "$pipx_version") \
    (__tool_line "󰔛" "uv" "$uv_version")

set -l python_lines (__python_lines)

set -l system_lines \
    (__tool_line "" "git" "$git_version") \
    (__tool_line "" "gh" "$gh_version")

set -l infra_lines \
    (__tool_line "" "docker" "$docker_version") \
    (__tool_line "" "compose" "$compose_version") \
    (__tool_line "󱃾" "kubectl" "$kubectl_version")

set -l total_lines (math (count $runtime_lines) + (count $package_lines) + (count $python_lines) + (count $system_lines) + (count $infra_lines))

if test $total_lines -eq 0
    exit 0
end

echo "$muted────────────────────────────────────────────$normal"
echo "$title"Dev Tools"$normal"
echo "$muted────────────────────────────────────────────$normal"
__print_section "$runtime_color" "Runtimes" $runtime_lines
__print_section "$package_color" "Package managers" $package_lines
__print_section "$python_color" "Python" $python_lines
__print_section "$system_color" "System tools" $system_lines
__print_section "$infra_color" "Infrastructure" $infra_lines
