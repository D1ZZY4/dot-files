# Suppress Fish's default welcome message.
# Fastfetch startup banner and Dev Tools take over this responsibility.

if status --is-interactive
    functions -q fish_greeting; and functions -e fish_greeting
    set -e -U fish_greeting 2>/dev/null
end
