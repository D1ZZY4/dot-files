# Startup banner: Fastfetch system summary and Dev Tools.
# Backgrounded to ensure zero shell startup latency.
# Output will render shortly after the prompt displays.

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
