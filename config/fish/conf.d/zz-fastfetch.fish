# Fastfetch. Backgrounded so it doesn't slow down shell startup.

if status is-interactive
    if command -q fastfetch
        begin
            functions -q fastfetch-apply-welcome; and fastfetch-apply-welcome
            fastfetch --config "$HOME/.config/fastfetch/config.jsonc"
        end &
    end
end
