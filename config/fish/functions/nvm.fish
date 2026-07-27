function nvm --description 'Node Version Manager wrapper (lazy-loads nvm on first call)'
    if test -f "$HOME/.nvm/nvm.sh"
        bash -lc "source '$HOME/.nvm/nvm.sh' && nvm \"\$@\"" -- $argv
    else if test -f /usr/share/nvm/init-nvm.sh
        bash -lc 'source /usr/share/nvm/init-nvm.sh && nvm "$@"' -- $argv
    else
        echo "nvm: not found (expected \$HOME/.nvm/nvm.sh or /usr/share/nvm/init-nvm.sh)" >&2
        return 1
    end
end
