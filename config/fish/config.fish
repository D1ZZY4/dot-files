function nvm
    if test -f "$HOME/.nvm/nvm.sh"
        bash -lc "source '$HOME/.nvm/nvm.sh' && nvm \"\$@\"" -- $argv
    else if test -f /usr/share/nvm/init-nvm.sh
        bash -lc 'source /usr/share/nvm/init-nvm.sh && nvm "$@"' -- $argv
    else
        echo "nvm: not found (expected \$HOME/.nvm/nvm.sh or /usr/share/nvm/init-nvm.sh)" >&2
        return 1
    end
end

if test -f /usr/share/cachyos-fish-config/cachyos-config.fish
    source /usr/share/cachyos-fish-config/cachyos-config.fish
end

# Fish loads files in conf.d/*.fish automatically before this file.
# Keep this file small; put shell setup in modular files under conf.d/.
