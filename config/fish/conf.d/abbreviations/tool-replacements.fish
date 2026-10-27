# Tool replacements: swap standard CLI tools with modern alternatives.
# Requires the replacement tool to be installed.

if not status is-interactive
    exit 0
end

if command -q bat
    abbr -a cat bat
end

if command -q fd
    abbr -a find fd
end

if command -q rg
    abbr -a grep rg
end

if command -q dust
    abbr -a du dust
end

if command -q procs
    abbr -a ps procs
end

if command -q zoxide
    abbr -a cd z
end