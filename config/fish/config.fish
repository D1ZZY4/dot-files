function nvm
    bash -lc 'source /usr/share/nvm/init-nvm.sh && nvm "$@"' -- $argv
end

if test -f /usr/share/cachyos-fish-config/cachyos-config.fish
    source /usr/share/cachyos-fish-config/cachyos-config.fish
end

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end

# Fish loads files in conf.d/*.fish automatically before this file.
# Keep this file small; put shell setup in modular files under conf.d/.
