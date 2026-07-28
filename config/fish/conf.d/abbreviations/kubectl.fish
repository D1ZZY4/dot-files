# Kubernetes abbreviations (requires kubectl).

if not status --is-interactive
    exit 0
end

if type -q kubectl
    abbr -a k kubectl
    abbr -a kx 'kubectl exec -it'
    abbr -a kl 'kubectl logs -f'
    abbr -a kctx 'kubectl config use-context'
    abbr -a kns 'kubectl config set-context --current --namespace'
end