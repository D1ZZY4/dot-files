# Fish completions for starship-dotfiles

complete -c starship-dotfiles -f -n "__fish_use_subcommand" -xa "(__fish_complete_subcommand)"

complete -c starship-dotfiles -s s -l style -d 'Set separator style (1-5)' -r -a "1 2 3 4 5"
complete -c starship-dotfiles -s c -l color -d 'Set color theme' -r -a "moonlight catppuccin-macchiato"
complete -c starship-dotfiles -s u -l username -d 'Set Fastfetch welcome name (use "reset" for system user)' -r
complete -c starship-dotfiles -l enable-module -d 'Enable a Starship module' -r -a "core directory git languages package file-icons"
complete -c starship-dotfiles -l disable-module -d 'Disable a Starship module (core cannot be disabled)' -r -a "directory git languages package file-icons"
complete -c starship-dotfiles -l list-modules -d 'List all available modules and their status'
complete -c starship-dotfiles -l explain -d 'Explain the current Starship prompt structure'
complete -c starship-dotfiles -l check-fast -d 'Run status checks on Starship, Fastfetch, Dev Tools, and modules'

complete -c starship-dotfiles -n "not __fish_seen_subcommand_from enable-module disable-module username style color explain check-fast list-modules dev-tools" -f -a "init"
complete -c starship-dotfiles -n "__fish_seen_subcommand_from dev-tools" -f -xa "init toggle"

complete -c starship-dotfiles -n "__fish_seen_subcommand_from enable-module" -f -a "core directory git languages package file-icons"
complete -c starship-dotfiles -n "__fish_seen_subcommand_from disable-module" -f -a "directory git languages package file-icons"

complete -c starship-dotfiles -n "__fish_seen_subcommand_from toggle" -f -xa \
  "nodejs deno bun go rustc java npm pnpm yarn cargo pipx uv git gh docker compose kubectl"
