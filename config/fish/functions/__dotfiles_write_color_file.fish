function __dotfiles_write_color_file --argument-names color path
    printf '%s\n' \
        '# Starship color palette name. Must match colors/<name>.toml' \
        '# Options: moonlight | catppuccin-macchiato | catppuccin-mocha' \
        "$color" > "$path"
end
