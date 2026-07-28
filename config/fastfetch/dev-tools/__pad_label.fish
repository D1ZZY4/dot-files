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
