# Abbreviations expand on SPACE/ENTER. Interactive only.
# Guarded with type checks so missing tools don't break things.

# Inline preference reader (avoids autoload dependency at config time).
function __dotfiles_abbr_read -a file
    if test -f "$file"
        while read -l line
            set -l trimmed (string trim -- $line)
            if test -n "$trimmed"; and not string match -qr '^#' -- "$trimmed"
                echo "$trimmed"
                return 0
            end
        end < "$file"
    end
end

if status --is-interactive

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

if type -q eza
    # ls/ll style from preference files (set via dot-files --ls-style/--ll-style)
    set -l __ls_group ""
    if test (__dotfiles_abbr_read "$HOME/.config/starship/ls-group" ) = "on"
        set __ls_group "--group-directories-first"
    end

    switch (__dotfiles_abbr_read "$HOME/.config/starship/ls-style" )
        case 1; abbr -a ls "eza --icons=always $__ls_group"
        case 2; abbr -a ls "eza -1 --icons=always $__ls_group"
        case 3; abbr -a ls "eza --icons=always -T -L=1 $__ls_group"
        case 5; abbr -a ls "eza --icons=always --git $__ls_group"
        case '*'; abbr -a ls "eza --icons=always -T -L=1 $__ls_group"
    end

    switch (__dotfiles_abbr_read "$HOME/.config/starship/ll-style" )
        case 1; abbr -a ll "eza -la --icons=always $__ls_group"
        case 2; abbr -a ll "eza -la --icons=always --header $__ls_group"
        case 3; abbr -a ll "eza -la --icons=always --git $__ls_group"
        case 4; abbr -a ll "eza -la --icons=always --header --group --time-style=iso $__ls_group"
        case '*'; abbr -a ll "eza -la --icons=always --git $__ls_group"
    end

    abbr -a lt 'eza --tree --level=2 --icons'
    abbr -a lta 'eza --tree --level=3 --icons -a'
else if type -q lsd
    abbr -a ls 'lsd --icon always'
    abbr -a ll 'lsd -la --icon always'
    abbr -a lt 'lsd --tree --depth 2'
    abbr -a lta 'lsd --tree --depth 3 -a'
end

if type -q bat
    abbr -a cat bat
end

if type -q fd
    abbr -a find fd
end

if type -q rg
    abbr -a grep rg
end

if type -q dust
    abbr -a du dust
end

if type -q procs
    abbr -a ps procs
end

if type -q zoxide
    abbr -a cd z
end

if type -q kubectl
    abbr -a k kubectl
    abbr -a kx 'kubectl exec -it'
    abbr -a kl 'kubectl logs -f'
    abbr -a kctx 'kubectl config use-context'
    abbr -a kns 'kubectl config set-context --current --namespace'
end

if type -q docker
    abbr -a d docker
    abbr -a dco 'docker compose'
    abbr -a dps 'docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
    abbr -a dcu 'docker compose up -d'
    abbr -a dcd 'docker compose down'
end

if type -q gh
    abbr -a ghg 'gh browse'
    abbr -a ghpr 'gh pr create --fill'
    abbr -a ghrv 'gh repo view --web'
    abbr -a ghi 'gh issue list'
end

abbr -a .. 'cd ..'
abbr -a ... 'cd ../..'
abbr -a .... 'cd ../../..'
abbr -a ..... 'cd ../../../..'

abbr -a c clear
abbr -a cl clear
abbr -a h history
abbr -a j jobs

abbr -a tf terraform
abbr -a tfi 'terraform init'
abbr -a tfp 'terraform plan'
abbr -a tfa 'terraform apply'

abbr -a dotf 'dot-files'
end
