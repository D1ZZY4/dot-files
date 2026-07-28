if test -f /usr/share/cachyos-fish-config/cachyos-config.fish
    source /usr/share/cachyos-fish-config/cachyos-config.fish
    # CachyOS defines fish_greeting which runs fastfetch. Our
    # zz-fastfetch.fish handles Fastfetch + Dev Tools instead,
    # so suppress the CachyOS greeting to avoid a double render.
    functions -q fish_greeting; and functions -e fish_greeting
    set -e -U fish_greeting 2>/dev/null
end

# Sensible default editor — only if the user hasn't already chosen one.
set -q EDITOR; or set -gx EDITOR vim

# Function nvm is defined lazily: only wraps nvm when the user calls it.
# The actual nvm init happens inside the function body on first invocation.

# Fish loads files in conf.d/*.fish automatically before this file.
# Keep this file small; put shell setup in modular files under conf.d/.
