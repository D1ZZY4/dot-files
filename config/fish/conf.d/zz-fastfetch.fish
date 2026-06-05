# Startup banner: Fastfetch system summary, then Dev Tools (dev-tools.fish).
# Loaded late (zz-*) so version managers (nvm, etc.) are on PATH first.

if status --is-interactive
    if type -q fastfetch
        if functions -q fastfetch-apply-welcome
            fastfetch-apply-welcome
        end
        fastfetch --config "$HOME/.config/fastfetch/config.jsonc"
    end

    if test -f "$HOME/.config/fastfetch/dev-tools.fish"
        fish "$HOME/.config/fastfetch/dev-tools.fish"
    end
end
