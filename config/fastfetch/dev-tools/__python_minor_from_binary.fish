function __python_minor_from_binary
    set -l name (command basename "$argv[1]")
    string replace -r '^python' '' -- "$name"
end
