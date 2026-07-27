# Icon-aware ls for Fish when eza/lsd are not installed.
# Prefers: eza -> lsd -> built-in column/long listing with Nerd Font icons.

function ls --description 'List files with Nerd Font icons' --wraps ls
    if type -q eza
        command eza --icons=always --group-directories-first -- $argv
        return $status
    else if type -q lsd
        command lsd --icon always --group-dirs first -- $argv
        return $status
    end

    set -l show_all 0
    set -l long 0
    set -l paths

    for arg in $argv
        switch $arg
            case -a --all
                set show_all 1
            case -A --almost-all
                set show_all 1
            case -l
                set long 1
            case -la -al -lA -Al
                set long 1
                set show_all 1
            case '-*'
                command ls --color=auto -- $argv
                return $status
            case '*'
                set -a paths $arg
        end
    end

    if test (count $paths) -eq 0
        set paths .
    end

    set -l multiple 0
    if test (count $paths) -gt 1
        set multiple 1
    end

    for target in $paths
        if test $multiple -eq 1
            echo "$target:"
        end

        if test $long -eq 1
            __ls_long_icons "$target" $show_all
        else
            __ls_column_icons "$target" $show_all
        end

        if test $multiple -eq 1
            echo
        end
    end
end

function __ls_entries -a target show_all
    if test -d "$target"
        if test "$show_all" = 1
            echo .
            echo ..
            command ls -A "$target" 2>/dev/null
        else
            command ls "$target" 2>/dev/null
        end
    else
        basename "$target"
    end
end

function __ls_full_path -a target name
    if test "$name" = .
        echo "$target"
    else if test "$name" = ..
        dirname "$target"
    else if test -d "$target"
        echo "$target/$name"
    else
        echo "$target"
    end
end

function __ls_column_icons -a target show_all
    set -l rendered

    for name in (__ls_entries "$target" $show_all)
        set -l full (__ls_full_path "$target" "$name")
        set -l icon (__ls_icon "$name" "$full")
        set -a rendered "$icon  $name"
    end

    if test (count $rendered) -gt 0
        string join \n $rendered | command column
    end
end

function __ls_long_icons -a target show_all
    if test -d "$target"
        command ls -la "$target" 2>/dev/null | command head -n 1
    end

    for name in (__ls_entries "$target" $show_all)
        set -l full (__ls_full_path "$target" "$name")
        if not test -e "$full"; and not test -L "$full"
            continue
        end

        set -l icon (__ls_icon "$name" "$full")
        set -l perms (command stat -c '%A' -- "$full" 2>/dev/null)
        set -l links (command stat -c '%h' -- "$full" 2>/dev/null)
        set -l user (command stat -c '%U' -- "$full" 2>/dev/null)
        set -l group (command stat -c '%G' -- "$full" 2>/dev/null)
        set -l size (command stat -c '%s' -- "$full" 2>/dev/null)
        set -l mtime_raw (command stat -c '%y' -- "$full" 2>/dev/null)
        set -l mtime (command date -d "$mtime_raw" '+%b %e %H:%M' 2>/dev/null)
        set -l display "$name"

        if test -L "$full"
            set -l link_target (command readlink "$full" 2>/dev/null)
            set display "$name -> $link_target"
        end

        echo "$perms $links $user $group $size $mtime  $icon  $display"
    end
end

function __ls_icon -a name full
    set -l icon "󰈔"
    set -l lower (string lower -- "$name")

    if test -d "$full"
        set icon ""
        switch $lower
            case .git
                set icon ""
            case node_modules
                set icon ""
            case .config config configs
                set icon ""
            case desktop
                set icon ""
            case documents docs documentation
                set icon "󰈙"
            case downloads
                set icon ""
            case music
                set icon "󰝚"
            case pictures images image img
                set icon ""
            case videos
                set icon ""
            case public
                set icon ""
            case templates
                set icon ""
            case 'my projects' projects developer dev
                set icon "󰲋"
            case src source sources
                set icon "󰉿"
            case scripts script bin
                set icon ""
            case dist build out target
                set icon "󰏖"
            case test tests __tests__ spec specs
                set icon "󰙨"
            case .venv venv
                set icon ""
            case .github
                set icon ""
        end
    else
        switch $lower
            case .gitignore .gitattributes .gitmodules
                set icon ""
            case package.json package-lock.json npm-shrinkwrap.json
                set icon ""
            case pnpm-lock.yaml pnpm-workspace.yaml
                set icon ""
            case yarn.lock
                set icon ""
            case bun.lockb bunfig.toml
                set icon ""
            case deno.json deno.jsonc
                set icon ""
            case dockerfile docker-compose.yml docker-compose.yaml compose.yml compose.yaml
                set icon ""
            case makefile cmakelists.txt
                set icon ""
            case readme 'readme.*' license 'license.*' changelog 'changelog.*' agents.md plan.md replit.md
                set icon "󰈙"
            case '*.zip' '*.rar' '*.7z' '*.tar' '*.gz' '*.tgz' '*.xz' '*.bz2' '*.zst' '*.iso'
                set icon ""
            case '*.sh' '*.bash' '*.zsh' '*.fish' '*.ksh' '*.env' '*.env.*'
                set icon ""
            case '*.png' '*.jpg' '*.jpeg' '*.gif' '*.webp' '*.bmp' '*.tiff' '*.ico' '*.svg' '*.avif'
                set icon ""
            case '*.mp4' '*.mkv' '*.mov' '*.avi' '*.webm'
                set icon ""
            case '*.mp3' '*.wav' '*.flac' '*.ogg' '*.m4a'
                set icon "󰝚"
            case '*.py' '*.pyw' '*.ipynb'
                set icon ""
            case '*.ts' '*.tsx'
                set icon ""
            case '*.js' '*.jsx' '*.mjs' '*.cjs'
                set icon ""
            case '*.json' '*.jsonc'
                set icon ""
            case '*.go'
                set icon ""
            case '*.rs'
                set icon ""
            case '*.java' '*.jar' '*.gradle'
                set icon ""
            case '*.kt' '*.kts'
                set icon ""
            case '*.php'
                set icon ""
            case '*.rb' gemfile rakefile
                set icon ""
            case '*.lua'
                set icon ""
            case '*.c' '*.h'
                set icon ""
            case '*.cpp' '*.cc' '*.cxx' '*.hpp' '*.hh' '*.hxx'
                set icon ""
            case '*.cs'
                set icon "󰌛"
            case '*.swift'
                set icon ""
            case '*.dart'
                set icon ""
            case '*.vue'
                set icon ""
            case '*.svelte'
                set icon ""
            case '*.html' '*.htm'
                set icon ""
            case '*.css' '*.scss' '*.sass' '*.less'
                set icon ""
            case '*.toml'
                set icon ""
            case '*.yml' '*.yaml'
                set icon ""
            case '*.xml'
                set icon "󰗀"
            case '*.md' '*.markdown' '*.mdx'
                set icon ""
            case '*.txt' '*.log'
                set icon "󰈙"
            case '*.pdf'
                set icon ""
            case '*.db' '*.sqlite' '*.sqlite3' '*.sql'
                set icon ""
            case '*.ttf' '*.otf' '*.woff' '*.woff2'
                set icon ""
            case '*.lock'
                set icon ""
            case .replit replit.nix
                set icon ""
        end
    end

    echo "$icon"
end
