# Startup banner: Fastfetch system summary and Dev Tools.
# Backgrounded to ensure zero shell startup latency.
# Output will render shortly after the prompt displays.

if status --is-interactive
    if type -q fastfetch
        # Apply welcome name synchronously (fast file I/O)
        if functions -q fastfetch-apply-welcome
            fastfetch-apply-welcome
        end

        # Run everything in background for instant prompt
        begin
            fastfetch --config "$HOME/.config/fastfetch/config.jsonc"
            if test -f "$HOME/.config/fastfetch/dev-tools.fish"
                fish "$HOME/.config/fastfetch/dev-tools.fish"
            end
        end &
    end
end
