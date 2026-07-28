# Initialize Starship prompt for interactive Fish sessions.
# Config path: ~/.config/starship.toml (symlink to starship/starship.toml).
# Deferred to first prompt render to avoid spawning the Rust binary on every startup.

if status --is-interactive
    function __starship_init --on-event fish_prompt --inherit-variable _starship_ran
        if set -q _starship_ran
            return
        end
        set -g _starship_ran 1
        type -q starship; and starship init fish | source
    end
end
