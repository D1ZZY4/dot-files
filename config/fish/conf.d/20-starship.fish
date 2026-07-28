# Starship prompt. Config: ~/.config/starship.toml.
# Deferred to first prompt to avoid spawning the Rust binary on every shell start.

if status --is-interactive
    function __starship_init --on-event fish_prompt
        if set -q __starship_initialized
            return
        end
        set -g __starship_initialized 1
        type -q starship; and command starship init fish | source
    end
end
