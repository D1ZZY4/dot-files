# Regenerate ~/.config/starship/starship.toml from modules/, style, and color.

function starship-rebuild --description 'Rebuild modular Starship config from source modules'
    fish "$HOME/.config/starship/build.fish"
end
