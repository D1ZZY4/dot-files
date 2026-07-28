# Sync Fastfetch title from starship/username into config.jsonc.
# Empty -> Welcome, {user-name}!  (system username)
# Custom -> Welcome, Your Name!
function fastfetch-apply-welcome --description 'Apply starship/username to Fastfetch config title'
    set -l fastfetch_config "$HOME/.config/fastfetch/config.jsonc"
    set -l username_file "$HOME/.config/starship/username"
    set -l legacy_username_file "$HOME/.config/fastfetch/username"

    # Migrate from old fastfetch/username location.
    if not test -f "$username_file"; and test -f "$legacy_username_file"
        mkdir -p (dirname "$username_file")
        mv "$legacy_username_file" "$username_file"
    end

    if not test -f "$fastfetch_config"
        echo "dot-files: fastfetch config not found at $fastfetch_config" >&2
        return 1
    end

    set -l format_line '"format": "Welcome, {user-name}!"'
    set -l display_name (dotfiles-read-setting "$username_file")
    if test -n "$display_name"
        set -l safe_name (string escape --style=json -- "$display_name")
        set format_line '"format": "Welcome, '"$safe_name"'!"'
    end

    # mktemp with template: portable across GNU and BSD/macOS.
    set -l tmp (mktemp /tmp/dotfiles.XXXXXX)
    if test -z "$tmp"
        echo "dot-files: mktemp failed" >&2
        return 1
    end
    # string replace -r always exits 0, so check the pattern exists first.
    if grep -q '"format": "Welcome, [^"]*!"' "$fastfetch_config"
        string replace -r '"format": "Welcome, [^"]*!"' "$format_line" \
            < "$fastfetch_config" > "$tmp"
        mv -- "$tmp" "$fastfetch_config"
    else
        rm -f "$tmp"
        echo "dot-files: 'format' line not found in $fastfetch_config" >&2
        return 1
    end
end
