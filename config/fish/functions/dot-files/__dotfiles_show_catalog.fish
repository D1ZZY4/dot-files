function __dotfiles_show_catalog --argument-names style_file color_file username_file modules_file
    set -l heading (set_color --bold)
    set -l muted (set_color brblack)
    set -l normal (set_color normal)

    set -l saved_style (dotfiles-read-setting "$style_file"; or echo 5)
    set -l saved_color (dotfiles-read-setting "$color_file"; or echo moonlight)
    set -l active_username (dotfiles-read-setting "$username_file")
    if test -z "$active_username"
        set active_username "(system: {user-name})"
    end

    set -l enabled_modules (dotfiles-read-modules "$modules_file")

    echo "$heading""Usage$normal"
    echo "  dot-files --style 1|2|3|4|5"
    echo "  dot-files --color moonlight|catppuccin-macchiato|catppuccin-mocha"
    echo "  dot-files --username NAME"
    echo "  dot-files --username reset"
    echo "  dot-files --edit style|color|modules|username|dev-tools"
    echo "  dot-files --enable-module core|directory|git|languages|package|file-icons"
    echo "  dot-files --disable-module core|directory|git|languages|package|file-icons"
    echo "  dot-files --list-modules"
    echo "  dot-files --dev-tools init|toggle|reload"
    echo "  dot-files --doctor"
    echo "  dot-files --status"
    echo "  dot-files --ls-style 1|2|3|5"
    echo "  dot-files --ll-style 1|2|3|4"
    echo "  dot-files --ls-group on|off"
    echo ""
    echo "$heading""Active$normal"
    echo "  style:    $saved_style"
    echo "  color:    $saved_color"
    echo "  username: $active_username"
    if test (count $enabled_modules) -gt 0
        echo "  modules:  "(string join ', ' $enabled_modules)
    else
        echo "  modules:  (all enabled)"
    end
    echo ""
    echo "$heading""Preference files$normal"
    echo "  $style_file"
    echo "  $color_file"
    echo "  $username_file"
    echo "  $modules_file"
    echo ""
    echo "$heading""Styles$normal $muted(real prompt from your shell * = active)$normal"

    for style_check in 1 2 3 4 5
        set -lx STARSHIP_STYLE_PREVIEW $style_check
        set -lx STARSHIP_COLOR_PREVIEW $saved_color
        __dotfiles_rebuild_quiet
        set -l marker (__dotfiles_active_marker $style_check $saved_style)
        __dotfiles_print_prompt_preview "$marker$style_check"
    end

    echo ""
    echo "$heading""Colors$normal $muted(style 5 real prompt * = active)$normal"

    for color_check in moonlight catppuccin-macchiato catppuccin-mocha
        set -lx STARSHIP_STYLE_PREVIEW 5
        set -lx STARSHIP_COLOR_PREVIEW $color_check
        __dotfiles_rebuild_quiet
        set -l marker (__dotfiles_active_marker $color_check $saved_color)
        __dotfiles_print_prompt_preview "$marker$color_check"
    end

    set -e STARSHIP_STYLE_PREVIEW
    set -e STARSHIP_COLOR_PREVIEW
    __dotfiles_rebuild_quiet

    echo ""
    echo "$heading""Fastfetch welcome$normal"
    set -l yellow (set_color yellow)
    echo "  $muted(system)$normal  Welcome, $yellow"{user-name}"$normal!"
    echo "  $muted(custom)$normal   Welcome, "$yellow"Alex"$normal"!"
end
