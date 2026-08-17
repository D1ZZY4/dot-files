# Abbreviations loader — sources all modular abbreviation files.
# Each file sets up abbreviations for a specific tool category.
if status --is-interactive
    for f in (dirname (status --current-filename))/abbreviations/*.fish
        test -f "$f"; and source "$f"
    end
end