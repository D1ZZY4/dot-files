# Completions for dot-files.
# Module lists are generated from __dotfiles_all_modules when available,
# falling back to the canonical list if the function isn't loaded yet.
# Edit the canonical list in functions/dot-files.fish — not here.

complete -c dot-files -f
complete -c dot-files -s s -l style -x -a '1 2 3 4 5' -d 'Set separator style (1-5)'
complete -c dot-files -s c -l color -x -a 'moonlight catppuccin-macchiato catppuccin-mocha' -d 'Set color palette'
complete -c dot-files -s u -l username -x -d 'Set Fastfetch welcome name ("reset" for system user)'

# Build module completion candidates from __dotfiles_all_modules, excluding core.
# Must be a single space-separated string for complete -a.
set -l _dotfiles_module_opts
if functions -q __dotfiles_all_modules
    for m in (__dotfiles_all_modules)
        if test "$m" != core
            set -a _dotfiles_module_opts "$m"
        end
    end
else
    set _dotfiles_module_opts directory git languages package file-icons
end
set _dotfiles_module_opts (string join ' ' $_dotfiles_module_opts)
complete -c dot-files -l enable-module -x -d 'Enable a Starship module' -a "$_dotfiles_module_opts"
complete -c dot-files -l disable-module -x -d 'Disable a Starship module (core is required)' -a "$_dotfiles_module_opts"

complete -c dot-files -l list-modules -d 'List modules and their status'
complete -c dot-files -l dev-tools -x -a 'init toggle' -d 'Manage the dev-tools config or toggle a tool'
complete -c dot-files -n '__fish_seen_subcommand_from toggle' -f -a \
    'nodejs deno bun go rustc java npm pnpm yarn cargo pipx uv python git gh docker compose kubectl'
complete -c dot-files -l edit -x -a 'style color modules username dev-tools' -d 'Open a preference file in \$EDITOR and rebuild'
