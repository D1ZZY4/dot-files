# Initialize Starship prompt for interactive Fish sessions.
# Config path: ~/.config/starship.toml (symlink to starship/starship.toml).

if status --is-interactive
    type -q starship; and starship init fish | source
end
