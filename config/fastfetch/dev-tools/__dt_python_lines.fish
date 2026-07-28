function __dt_python_lines
    set -l rows
    for binary in (__dt_collect_python_binaries)
        set -l minor (__python_minor_from_binary "$binary")
        set -l py_version_value (__python_version_from_binary "$binary")
        if test -n "$minor"; and test -n "$py_version_value"
            set -a rows "$minor - $py_version_value"
        end
    end
    set rows (string join \n $rows | sort -n | uniq)
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
