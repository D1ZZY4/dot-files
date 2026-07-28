if test -f /usr/share/cachyos-fish-config/cachyos-config.fish
    source /usr/share/cachyos-fish-config/cachyos-config.fish
    # CachyOS defines fish_greeting that runs fastfetch. Our
    # zz-fastfetch.fish handles it with Dev Tools, so suppress the
    # CachyOS greeting to avoid double render.
    functions -q fish_greeting; and functions -e fish_greeting
    set -e -U fish_greeting 2>/dev/null
end

# Default editor if none set.
set -q EDITOR; or set -gx EDITOR vim

# nvm is lazy-loaded: only initialized when first called.

# Fish loads conf.d/*.fish automatically before this file.
# Keep this minimal; put setup in conf.d/.
