function __dt_enabled
    set -l tool $argv[1]
    if test -z "$tool"
        return 1
    end
    if test -f "$__dt_config_file"
        # Quote the regex pattern to prevent Fish glob expansion of [[:space:]].
        grep -q -- "^$tool"'[[:space:]]*=[[:space:]]*false' "$__dt_config_file" 2>/dev/null
        and return 1
    end
    return 0
end
