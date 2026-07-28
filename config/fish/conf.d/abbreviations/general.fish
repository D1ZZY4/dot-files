# General / navigation abbreviations.

if not status --is-interactive
    exit 0
end

abbr -a dotf dot-files

abbr -a .. 'cd ..'
abbr -a ... 'cd ../..'
abbr -a .... 'cd ../../..'
abbr -a ..... 'cd ../../../..'

abbr -a c clear
abbr -a cl clear
abbr -a h history
abbr -a j jobs