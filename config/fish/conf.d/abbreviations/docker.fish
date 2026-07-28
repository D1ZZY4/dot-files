# Docker abbreviations (requires docker).

if not status --is-interactive
    exit 0
end

if type -q docker
    abbr -a d docker
    abbr -a dco 'docker compose'
    abbr -a dps 'docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
    abbr -a dcu 'docker compose up -d'
    abbr -a dcd 'docker compose down'
end