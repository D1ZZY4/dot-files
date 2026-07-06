# Completions for dot-files.

complete -c dot-files -f
complete -c dot-files -s s -l style -x -a '1 2 3 4 5' -d 'Set separator style (1-5)'
complete -c dot-files -s c -l color -x -a 'moonlight catppuccin-macchiato catppuccin-mocha' -d 'Set color palette'
complete -c dot-files -s u -l username -x -d 'Set Fastfetch welcome name ("reset" for system user)'
complete -c dot-files -l enable-module -x -a 'core directory git languages package file-icons' -d 'Enable a Starship module'
complete -c dot-files -l disable-module -x -a 'directory git languages package file-icons' -d 'Disable a Starship module (core is required)'
complete -c dot-files -l list-modules -d 'List modules and their status'
complete -c dot-files -l dev-tools -x -a 'init toggle' -d 'Manage the dev-tools config or toggle a tool'
complete -c dot-files -n '__fish_seen_subcommand_from toggle' -f -a \
    'nodejs deno bun go rustc java npm pnpm yarn cargo pipx uv python git gh docker compose kubectl'
