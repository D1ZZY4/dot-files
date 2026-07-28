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
        case 5; echo "eza --icons=always --git $group"
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
        case '*'; echo "eza -la --icons=always --git $group"
    end
end
