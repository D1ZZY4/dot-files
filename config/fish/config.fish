if test -f /usr/share/cachyos-fish-config/cachyos-config.fish
    source /usr/share/cachyos-fish-config/cachyos-config.fish
end

# Sensible default editor — only if the user hasn't already chosen one.
set -q EDITOR; or set -gx EDITOR vim

# Function nvm is defined lazily: only wraps nvm when the user calls it.
# The actual nvm init happens inside the function body on first invocation.

# Fish loads files in conf.d/*.fish automatically before this file.
# Keep this file small; put shell setup in modular files under conf.d/.
