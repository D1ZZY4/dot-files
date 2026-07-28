function __dotfiles_write_style_file --argument-names style path
    printf '%s\n' \
        '# Starship powerline separator style (1-5).' \
        '# 1: block  2: gradient  3: angled  4: slant  5: round (default)' \
        "$style" > "$path"
end
