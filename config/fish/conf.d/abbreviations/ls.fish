# ls/ll abbreviation styles from preference files.
# Styles set via: dot-files --ls-style <N> / --ll-style <N> / --ls-group on|off

# Guard: interactive only
if not status --is-interactive
    exit 0
end

# Inline preference reader (avoids autoload dependency at config time).
function __dotfiles_abbr_read -a file
    if test -f "$file"
        while read -l line
            set -l trimmed (string trim -- $line)
            if test -n "$trimmed"; and not string match -qr '^#' -- "$trimmed"
                echo "$trimmed"
                return 0
            end
        end < "$file"
    end
end

if type -q eza
    set -l __ls_group ""
    if test (__dotfiles_abbr_read "$HOME/.config/starship/ls-group" ) = "on"
        set __ls_group "--group-directories-first"
    end

    # --- ls: style-dependent ---
    switch (__dotfiles_abbr_read "$HOME/.config/starship/ls-style" )
        case 1; abbr -a ls "eza --icons=always $__ls_group"
        case 2; abbr -a ls "eza -1 --icons=always $__ls_group"
        case 3; abbr -a ls "eza --icons=always -T -L=1 $__ls_group"
        case 4; abbr -a ls "eza --icons=always --git --header $__ls_group"
        case 5; abbr -a ls "eza --icons=always --git $__ls_group"
        case 6; abbr -a ls "eza --code --icons=always $__ls_group"
        case '*'; abbr -a ls "eza --icons=always -T -L=1 $__ls_group"
    end

    # --- ll: style-dependent ---
    switch (__dotfiles_abbr_read "$HOME/.config/starship/ll-style" )
        case 1; abbr -a ll "eza -la --icons=always $__ls_group"
        case 2; abbr -a ll "eza -la --icons=always --header $__ls_group"
        case 3; abbr -a ll "eza -la --icons=always --git $__ls_group"
        case 4; abbr -a ll "eza -la --icons=always --header --group --time-style=iso $__ls_group"
        case 5; abbr -a ll "eza -la --icons=always --header --git --inode $__ls_group"
        case 6; abbr -a ll "eza -la --icons=always --git --color-scale=all $__ls_group"
        case '*'; abbr -a ll "eza -la --icons=always --git $__ls_group"
    end

    # --- Common aliases ---
    abbr -a l "eza -1 --icons=always $__ls_group"
    abbr -a la "eza -la --icons=always $__ls_group"

    # --- Filter shortcuts ---
    abbr -a ld "eza -D --icons=always $__ls_group"
    abbr -a lf "eza -f --icons=always $__ls_group"
    abbr -a l. "eza -la -I='[!.]*' --icons=always $__ls_group"

    # --- Layout variants ---
    abbr -a lx "eza -x --icons=always $__ls_group"
    abbr -a lt 'eza --tree --level=2 --icons'
    abbr -a lta 'eza --tree --level=3 --icons -a'

    # --- Long-view feature shortcuts ---
    abbr -a lh "eza -la --icons=always --header $__ls_group"
    abbr -a li "eza -la --icons=always --inode $__ls_group"
    abbr -a lo "eza -la --icons=always --octal-permissions $__ls_group"
    abbr -a lg "eza -la --icons=always --git $__ls_group"
    abbr -a lgr "eza --git-repos --icons=always $__ls_group"
    abbr -a lgs "eza -la --icons=always --git --smart-group --time-style=iso $__ls_group"

    # --- Special / eza unique features ---
    abbr -a loc "eza --code --icons=always $__ls_group"
    abbr -a lc "eza --color-scale=all --icons=always $__ls_group"
    abbr -a lk "eza --hyperlink=always --icons=always $__ls_group"

else if type -q lsd
    abbr -a ls 'lsd --icon always'
    abbr -a ll 'lsd -la --icon always'
    abbr -a l  'lsd -1 --icon always'
    abbr -a la 'lsd -la --icon always'
    abbr -a ld 'lsd --tree --depth 1 -d --icon always'
    abbr -a lt 'lsd --tree --depth 2'
    abbr -a lta 'lsd --tree --depth 3 -a'
    abbr -a li 'lsd -la --icon always --inode'
end