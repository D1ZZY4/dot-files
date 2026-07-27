function nvm --description 'Node Version Manager wrapper (lazy-loads nvm on first call)'
    # nvm is a bash-only script; there is no Fish-native equivalent. When nvm
    # is not already loaded, this wrapper delegates to bash via `bash -lc`
    # so that nvm's initialization and argument handling work correctly.
    # Prefer an already-loaded nvm function (e.g. from a previous manual init),
    # then $NVM_DIR/nvm.sh, then the well-known distro install paths.
    if type -q nvm
        return 0
    end
    if test -n "$NVM_DIR" -a -f "$NVM_DIR/nvm.sh"
        bash -lc "source '$NVM_DIR/nvm.sh' && nvm \"\$@\"" -- $argv
    else if test -f "$HOME/.nvm/nvm.sh"
        bash -lc "source '$HOME/.nvm/nvm.sh' && nvm \"\$@\"" -- $argv
    else if test -f /usr/share/nvm/init-nvm.sh
        bash -lc 'source /usr/share/nvm/init-nvm.sh && nvm "$@"' -- $argv
    else
        echo "nvm: not found (set NVM_DIR or install to \$HOME/.nvm or /usr/share/nvm)" >&2
        return 1
    end
end
