function nvm
    bash -c "source /usr/share/nvm/init-nvm.sh && nvm $argv"
end

source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end

# Fish loads files in conf.d/*.fish automatically before this file.
# Keep this file small; put shell setup in modular files under conf.d/.

if functions -q fish_greeting
    functions -e fish_greeting
end
