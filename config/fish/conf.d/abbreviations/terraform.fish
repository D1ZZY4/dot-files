# Terraform abbreviations (requires terraform).

if not status --is-interactive
    exit 0
end

if type -q terraform
    abbr -a tf terraform
    abbr -a tfi 'terraform init'
    abbr -a tfp 'terraform plan'
    abbr -a tfa 'terraform apply'
end