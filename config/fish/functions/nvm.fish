function nvm --description 'Node Version Manager wrapper (lazy-loads nvm on first call)'
    # nvm is a bash-only script; there is no Fish-native equivalent. When nvm
    # is not already loaded, this wrapper delegates to bash so that nvm's
    # initialization and argument handling work correctly.
    # Use a marker flag to avoid the self-referential `type -q nvm` check
    # (which always succeeds since this function is named nvm).
    if set -q __nvm_loaded
        return 0
    end

    # NVM_DIR is passed as a positional arg to bash ($1) rather than
    # interpolated into the -c string, preventing single-quote breakout.
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
