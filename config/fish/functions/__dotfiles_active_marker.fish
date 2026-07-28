function __dotfiles_active_marker --argument-names value active
    if test "$value" = "$active"
        echo (set_color green)"*"(set_color normal)
    end
end
