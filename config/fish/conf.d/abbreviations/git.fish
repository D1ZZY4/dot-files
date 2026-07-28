# Git abbreviations (requires git).

if not status --is-interactive
    exit 0
end

if type -q git
    abbr -a g git
    abbr -a gst git status -sb
    abbr -a glog git log --oneline --graph --decorate --all
    abbr -a gd git diff
    abbr -a gds 'git diff --staged'
    abbr -a ga git add
    abbr -a gc git commit
    abbr -a gca 'git commit --amend --no-edit'
    abbr -a gco git checkout
    abbr -a gcb 'git checkout -b'
    abbr -a gp git push
    abbr -a gpl git pull --rebase
    abbr -a gstash git stash
    abbr -a gsw 'git switch'
end