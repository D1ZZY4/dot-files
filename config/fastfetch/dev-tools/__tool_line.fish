function __tool_line
    set -l icon $argv[1]
    set -l label $argv[2]
    set -l tool_version $argv[3]
    if test -n "$tool_version"
        set -l padded_label (__pad_label "$label" 10)
        echo "  $icon  $padded_label  $tool_version"
    end
end
