function nvm --description 'Node Version Manager wrapper (lazy-loads nvm on first call)'
    # nvm is bash-only, no Fish equivalent. Delegate to bash when not loaded.
    # Use a marker flag instead of `type -q nvm` — that always returns 0
    # (this function IS nvm).
    if set -q __nvm_loaded
        return 0
    end

    # Pass NVM_DIR as positional arg ($1) instead of interpolating into
    # the -c string. Prevents single-quote breakout.
    set -l nvm_dir
    set -l nvm_sh
    if test -n "$NVM_DIR" -a -f "$NVM_DIR/nvm.sh"
        set nvm_dir "$NVM_DIR"
        set nvm_sh "$NVM_DIR/nvm.sh"
    else if test -f "$HOME/.nvm/nvm.sh"
        set nvm_dir "$HOME/.nvm"
        set nvm_sh "$HOME/.nvm/nvm.sh"
    else if test -f /usr/share/nvm/init-nvm.sh
        set nvm_dir /usr/share/nvm
        set nvm_sh /usr/share/nvm/init-nvm.sh
    else
        echo "nvm: not found (set NVM_DIR or install to \$HOME/.nvm or /usr/share/nvm)" >&2
        return 1
    end

    bash -c 'source "$1" && nvm "${@:2}"' _ "$nvm_sh" $argv
    set -g __nvm_loaded 1
end
