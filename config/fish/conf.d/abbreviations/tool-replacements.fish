# Tool replacements: swap standard CLI tools with modern alternatives.
# Requires the replacement tool to be installed.

if not status --is-interactive
    exit 0
end

if type -q bat
    abbr -a cat bat
end

if type -q fd
    abbr -a find fd
end

if type -q rg
    abbr -a grep rg
end

if type -q dust
    abbr -a du dust
end

if type -q procs
    abbr -a ps procs
end

if type -q zoxide
    abbr -a cd z
end