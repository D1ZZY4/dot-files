# Initialize Starship prompt for interactive Fish sessions.
# Config path: ~/.config/starship.toml (symlink to starship/starship.toml).
# Deferred to first prompt render to avoid spawning the Rust binary on every startup.

if status --is-interactive
    function __starship_init --on-event fish_prompt
        if set -q __starship_initialized
            return
        end
        set -g __starship_initialized 1
        type -q starship; and starship init fish | source
    end
end
