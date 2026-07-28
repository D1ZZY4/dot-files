# Fastfetch + Dev Tools. Backgrounded so it doesn't slow down shell startup.

if status --is-interactive
    if type -q fastfetch
        begin
            functions -q fastfetch-apply-welcome; and fastfetch-apply-welcome
            fastfetch --config "$HOME/.config/fastfetch/config.jsonc"
            if test -f "$HOME/.config/fastfetch/dev-tools.fish"
                fish "$HOME/.config/fastfetch/dev-tools.fish"
            end
        end &
    end
end
