# Suppress Fish's default welcome message.
# Fastfetch startup banner and Dev Tools take over this responsibility.

if status --is-interactive
    set -l greeting_on 0
    if functions -q fish_greeting
        set greeting_on 1
    else if set -q fish_greeting
        if test -n "$fish_greeting"
            set greeting_on 1
        end
    end
    if test "$greeting_on" -eq 1
        functions -e fish_greeting 2>/dev/null
        set -e fish_greeting 2>/dev/null
    end
end
