# Completions for dot-files.
# Module list: uses __dotfiles_all_modules if loaded, falls back to hardcoded list.
# Edit source list in functions/dot-files.fish, not here.

complete -c dot-files -f
complete -c dot-files -s s -l style -x -a '1 2 3 4 5' -d 'Set separator style (1-5)'
complete -c dot-files -s c -l color -x -a 'moonlight catppuccin-macchiato catppuccin-mocha' -d 'Set color palette'
complete -c dot-files -s u -l username -x -a 'reset' -d 'Set Fastfetch welcome name ("reset" for system user)'

# Build module completion candidates (exclude core, must be space-separated).
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
complete -c dot-files -l doctor -d 'Run read-only sanity checks'
complete -c dot-files -l status -d 'Show dotfiles git status vs upstream'

complete -c dot-files -s e -l edit -x -a 'style color modules username' -d 'Open a preference file in \$EDITOR and rebuild'
complete -c dot-files -l ls-style -x -a '1 2 3 4 5 6' -d 'Set eza ls output style'
complete -c dot-files -l ll-style -x -a '1 2 3 4 5 6' -d 'Set eza ll output style'
complete -c dot-files -l ls-group -x -a 'on off' -d 'Group directories first'
