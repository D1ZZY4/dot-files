# General / navigation abbreviations.

if not status is-interactive
    exit 0
end

abbr -a dotf dot-files

# Navigation: skip when CachyOS defines the same functions via its aliases.
# CachyOS config.fish sources cachyos-config after conf.d, shadowing these.
if not path is -f /usr/share/cachyos-fish-config/cachyos-config.fish
    abbr -a .. 'cd ..'
    abbr -a ... 'cd ../..'
    abbr -a .... 'cd ../../..'
    abbr -a ..... 'cd ../../../..'
end

abbr -a c clear
abbr -a cl clear
abbr -a h history
abbr -a j jobs
