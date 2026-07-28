function __python_version_from_binary
    if test -x "$argv[1]"
        set -l py_version_value (command $argv[1] --version 2>/dev/null | string replace 'Python ' 'v')
        if test -n "$py_version_value"
            echo "$py_version_value"
        end
    end
end
