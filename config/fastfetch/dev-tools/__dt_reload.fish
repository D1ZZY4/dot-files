function __dt_reload
    set -l devtools_file "$__dt_config_file"
    if not test -f "$devtools_file"
        echo "dot-files: dev-tools config not found, run: dot-files --dev-tools init" >&2
        return 1
    end

    set -q __dt_config_file_mtime; or set -U __dt_config_file_mtime 0
    set -l current_mtime
    if command -v stat >/dev/null 2>&1
        set current_mtime (stat -c '%Y' "$devtools_file" 2>/dev/null)
        or set current_mtime (stat -f '%m' "$devtools_file" 2>/dev/null)
    end

    if test -z "$current_mtime"
        set -e __dt_enabled_map
        __dt_render
        echo "Dev Tools reloaded."
        return 0
    end

    if test "$current_mtime" = "$__dt_config_file_mtime"
        echo "Dev Tools reloaded (no changes detected)."
        return 0
    end

    set -e __dt_enabled_map
    __dt_render
    set -U __dt_config_file_mtime "$current_mtime"
    echo "Dev Tools reloaded."
end
