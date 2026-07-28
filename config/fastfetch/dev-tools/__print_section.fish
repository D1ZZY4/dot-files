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
