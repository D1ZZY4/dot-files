# Abbreviations expand on SPACE/ENTER in interactive sessions only.
# Guarded by type checks so they stay functional even when the target is missing.

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
    abbr -a ls eza
    abbr -a ll 'eza -la --icons'
    abbr -a lt 'eza --tree --level=2 --icons'
    abbr -a lta 'eza --tree --level=3 --icons -a'
else if type -q lsd
    abbr -a ls lsd
    abbr -a ll 'lsd -la'
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

if type -a procs >/dev/null 2>&1
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
