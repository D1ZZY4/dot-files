function __dotfiles_init_modules_file --argument-names modules_file
    if test -f "$modules_file"
        return 0
    end
    for module in (__dotfiles_all_modules)
        if test "$module" = file-icons
            echo "# $module"
        else
            echo "$module"
        end
    end > "$modules_file"
end
