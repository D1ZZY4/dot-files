# Abbreviations loader — sources all modular abbreviation files.
# Each file sets up abbreviations for a specific tool category.
for f in (dirname (status --current-filename))/abbreviations/*.fish
    test -f "$f"; and source "$f"
end