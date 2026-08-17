function __dotfiles_ls_read_style
    dotfiles-read-setting "$HOME/.config/starship/ls-style"
end

function __dotfiles_ll_read_style
    dotfiles-read-setting "$HOME/.config/starship/ll-style"
end

function __dotfiles_ls_group
    set -l val (dotfiles-read-setting "$HOME/.config/starship/ls-group")
    if test "$val" = on
        echo "--group-directories-first"
    end
end

function __dotfiles_ls_cmd
    set -l group (__dotfiles_ls_group)
    switch (__dotfiles_ls_read_style)
        case 1; echo "eza --icons=always $group"
        case 2; echo "eza -1 --icons=always $group"
        case 3; echo "eza --icons=always -T -L=1 $group"
        case 4; echo "eza --icons=always --git --header $group"
        case 5; echo "eza --icons=always --git $group"
        case 6; echo "eza --code --icons=always $group"
        case '*'; echo "eza --icons=always -T -L=1 $group"
    end
end

function __dotfiles_ll_cmd
    set -l group (__dotfiles_ls_group)
    switch (__dotfiles_ll_read_style)
        case 1; echo "eza -la --icons=always $group"
        case 2; echo "eza -la --icons=always --header $group"
        case 3; echo "eza -la --icons=always --git $group"
        case 4; echo "eza -la --icons=always --header --group --time-style=iso $group"
        case 5; echo "eza -la --icons=always --header --git --inode $group"
        case 6; echo "eza -la --icons=always --git --color-scale=all $group"
        case '*'; echo "eza -la --icons=always --git $group"
    end
end

# Return eza flags (no command) for a given ls style number — used by catalog previews.
function __dotfiles_ls_flags -a style
    switch $style
        case 1; echo ""
        case 2; echo "-1"
        case 3; echo "-T -L=1"
        case 4; echo "--git --header"
        case 5; echo "--git"
        case 6; echo "--code"
        case '*'; echo "-T -L=1"
    end
end

function __dotfiles_ll_flags -a style
    switch $style
        case 1; echo ""
        case 2; echo "--header"
        case 3; echo "--git"
        case 4; echo "--header --group --time-style=iso"
        case 5; echo "--header --git --inode"
        case 6; echo "--git --color-scale=all"
        case '*'; echo "--git"
    end
end

# Live preview: run eza for a given ls style number. Accepts optional dir arg (default: $HOME).
# --color=always ensures ANSI colors survive the pipe to sed in the catalog renderer.
function __dotfiles_ls_preview -a style
    set -l dir $HOME
    if set -q argv[2]
        set dir $argv[2]
    end
    set -l group (__dotfiles_ls_group)
    switch $style
        case 1; eza --color=always --icons=always $group $dir
        case 2; eza --color=always -1 --icons=always $group $dir
        case 3; eza --color=always --icons=always -T -L=1 $group $dir
        case 4; eza --color=always --icons=always --git --header $group $dir
        case 5; eza --color=always --icons=always --git $group $dir
        case 6; eza --color=always --code --icons=always $group $dir
        case '*'; eza --color=always --icons=always -T -L=1 $group $dir
    end
end

# Live preview: run eza for a given ll style number. Accepts optional dir arg (default: $HOME).
function __dotfiles_ll_preview -a style
    set -l dir $HOME
    if set -q argv[2]
        set dir $argv[2]
    end
    set -l group (__dotfiles_ls_group)
    switch $style
        case 1; eza --color=always -la --icons=always $group $dir
        case 2; eza --color=always -la --icons=always --header $group $dir
        case 3; eza --color=always -la --icons=always --git $group $dir
        case 4; eza --color=always -la --icons=always --header --group --time-style=iso $group $dir
        case 5; eza --color=always -la --icons=always --header --git --inode $group $dir
        case 6; eza --color=always -la --icons=always --git --color-scale=all $group $dir
        case '*'; eza --color=always -la --icons=always --git $group $dir
    end
end

# ---- ls/ll style preview generators ----

function __dotfiles_ls_style_preview -a style
    set -l cfg (__dotfiles_ls_group)
    switch $style
        case 1; echo "grid:       eza --icons=always $cfg"
        case 2; echo "one-per-ln: eza -1 --icons=always $cfg"
        case 3; echo "tree:       eza --icons=always -T -L=1 $cfg"
        case 4; echo "git+header: eza --icons=always --git --header $cfg"
        case 5; echo "git:        eza --icons=always --git $cfg"
        case 6; echo "loc:        eza --code --icons=always $cfg"
        case '*'; echo "tree:       eza --icons=always -T -L=1 $cfg"
    end
end

function __dotfiles_ll_style_preview -a style
    set -l cfg (__dotfiles_ls_group)
    switch $style
        case 1; echo "default:      eza -la --icons=always $cfg"
        case 2; echo "header:       eza -la --icons=always --header $cfg"
        case 3; echo "git:          eza -la --icons=always --git $cfg"
        case 4; echo "header+group: eza -la --icons=always --header --group --time-style=iso $cfg"
        case 5; echo "inode:        eza -la --icons=always --header --git --inode $cfg"
        case 6; echo "color-scale:  eza -la --icons=always --git --color-scale=all $cfg"
        case '*'; echo "git:          eza -la --icons=always --git $cfg"
    end
end
