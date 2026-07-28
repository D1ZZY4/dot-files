# GitHub CLI abbreviations (requires gh).

if not status --is-interactive
    exit 0
end

if type -q gh
    abbr -a ghg 'gh browse'
    abbr -a ghpr 'gh pr create --fill'
    abbr -a ghrv 'gh repo view --web'
    abbr -a ghi 'gh issue list'
end