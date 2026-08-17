function __dotfiles_starship_prompt_block
    set -l config "$HOME/.config/starship.toml"
    set -l term $TERM
    if test -z "$term"; or test "$term" = dumb
        set term xterm-256color
    end

    set -l lines (
        env TERM="$term" STARSHIP_CONFIG="$config" starship prompt --terminal-width 200 2>/dev/null \
            | string collect \
            | string trim --right -- \
            | string split \n
    )

    if test (count $lines) -ge 2
        set lines $lines[2..-1]
    end

    string trim --right -- (string join \n $lines)
end
