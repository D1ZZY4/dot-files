# Cache rendered prompt per style+color to avoid 9 starship spawns per catalog.
if not set -q __dotfiles_prompt_cache
    set -g __dotfiles_prompt_cache
end

function __dotfiles_print_prompt_preview --argument-names label
    echo "  $label"
    set -l cache_key "$STARSHIP_STYLE_PREVIEW:$STARSHIP_COLOR_PREVIEW"
    if not set -q __dotfiles_prompt_cache[$cache_key]
        set -g __dotfiles_prompt_cache[$cache_key] (__dotfiles_starship_prompt_block)
    end
    for line in (string split \n "$__dotfiles_prompt_cache[$cache_key]")
        echo "    $line"
    end
end
