function __dotfiles_print_prompt_preview --argument-names label
    echo "  $label"
    for line in (string split \n (__dotfiles_starship_prompt_block))
        echo "    $line"
    end
end
