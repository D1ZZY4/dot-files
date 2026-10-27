function nvm --description 'Node Version Manager wrapper (lazy-loads nvm on first call)'
    # nvm is bash-only, no Fish equivalent. Delegate to bash for each call.
    # BUG FIX: Removed the __nvm_loaded marker that made subsequent calls no-ops.
    set -l nvm_dir
    set -l nvm_sh
    if test -n "$NVM_DIR"; and path is -f "$NVM_DIR/nvm.sh"
        set nvm_dir "$NVM_DIR"
        set nvm_sh "$NVM_DIR/nvm.sh"
    else if path is -f "$HOME/.nvm/nvm.sh"
        set nvm_dir "$HOME/.nvm"
        set nvm_sh "$HOME/.nvm/nvm.sh"
    else if path is -f /usr/share/nvm/init-nvm.sh
        set nvm_dir /usr/share/nvm
        set nvm_sh /usr/share/nvm/init-nvm.sh
    else
        echo "nvm: not found (set NVM_DIR or install to \$HOME/.nvm or /usr/share/nvm)" >&2
        return 1
    end

    bash -c 'source "$1" && nvm "${@:2}"' _ "$nvm_sh" $argv
end
