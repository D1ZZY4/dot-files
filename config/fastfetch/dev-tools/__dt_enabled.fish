function __dt_enabled
    set -l tool $argv[1]
    if test -z "$tool"
        return 1
    end
    if test -f "$__dt_config_file"; and grep -q "^$tool[ 	]*=[ 	]*false" "$__dt_config_file" 2>/dev/null
        return 1
    end
    return 0
end
