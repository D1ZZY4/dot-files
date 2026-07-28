function __dotfiles_regex_escape
    set -l s $argv[1]
    string replace -a '\\\\' '\\\\' -- "$s" \
        | string replace -a '/' '\\/' \
        | string replace -a '.' '\\.' \
        | string replace -a '^' '\\^' \
        | string replace -a '$' '\\$' \
        | string replace -a '*' '\\*' \
        | string replace -a '+' '\\+' \
        | string replace -a '?' '\\?' \
        | string replace -a '[' '\\[' \
        | string replace -a ']' '\\]' \
        | string replace -a '(' '\\(' \
        | string replace -a ')' '\\)' \
        | string replace -a '{' '\\{' \
        | string replace -a '}' '\\}' \
        | string replace -a '|' '\\|' \
        | string replace -a '&' '\\&'
end
