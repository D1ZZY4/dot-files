# Initialize Starship prompt for interactive Fish sessions.
# Config path: ~/.config/starship.toml (symlink to starship/starship.toml).

if status --is-interactive
    if type -q starship
        starship init fish | source
    end
end
