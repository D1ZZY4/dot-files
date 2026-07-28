# Suppress Fish greeting. Fastfetch + Dev Tools handle startup.

if status --is-interactive
    functions -q fish_greeting; and functions -e fish_greeting
    set -e -U fish_greeting 2>/dev/null
end
