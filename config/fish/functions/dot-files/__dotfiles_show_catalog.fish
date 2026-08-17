function __dotfiles_show_catalog --argument-names style_file color_file username_file modules_file
    set -l heading (set_color --bold)
    set -l muted (set_color brblack)
    set -l normal (set_color normal)

    set -l saved_style (dotfiles-read-setting "$style_file"; or echo 5)
    set -l saved_color (dotfiles-read-setting "$color_file"; or echo moonlight)
    set -l active_username (dotfiles-read-setting "$username_file")
    or set active_username ""
    if test -z "$active_username"
        set active_username "system (Welcome, {user-name}!)"
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
    echo "  dot-files --ls-style 1|2|3|4|5|6"
    echo "  dot-files --ll-style 1|2|3|4|5|6"
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
    if type -q starship
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
    else
        echo "$heading""Styles$normal $muted(install starship to see previews)$normal"
        echo "$heading""Colors$normal $muted(install starship to see previews)$normal"
    end

    echo ""
    echo "$heading""Fastfetch welcome$normal"
    set -l yellow (set_color yellow)
    echo "  $muted(system)$normal  Welcome, $yellow"{user-name}"$normal!"
    echo "  $muted(custom)$normal   Welcome, "$yellow"Alex"$normal"!"

    # --- ls/ll style previews ---
    set -l style_dir (command dirname -- "$style_file")
    set -l saved_ls (dotfiles-read-setting "$style_dir/ls-style"; or echo 1)
    set -l saved_ll (dotfiles-read-setting "$style_dir/ll-style"; or echo 1)
    set -l saved_lsgrp (dotfiles-read-setting "$style_dir/ls-group"; or echo off)

    echo ""
    echo "$heading""ls/ll command previews$normal $muted(* = active)$normal"

    if type -q eza
        echo "  $heading""ls styles$normal"
        for s in 1 2 3 4 5 6
            set -l mkr (__dotfiles_active_marker $s $saved_ls)
            echo "  $mkr$s "
            set -lx STARSHIP_STYLE_PREVIEW $s
            set -lx STARSHIP_COLOR_PREVIEW $saved_color
            __dotfiles_rebuild_quiet
            eza --icons=always (__dotfiles_ls_group) (__dotfiles_ls_flags $s) --color=always $HOME 2>/dev/null | sed 's/^/    /'
        end

        echo ""
        echo "  $heading""ll styles$normal"
        for s in 1 2 3 4 5 6
            set -l mkr (__dotfiles_active_marker $s $saved_ll)
            echo "  $mkr$s "
            set -lx STARSHIP_STYLE_PREVIEW $s
            set -lx STARSHIP_COLOR_PREVIEW $saved_color
            __dotfiles_rebuild_quiet
            eza -la --icons=always (__dotfiles_ls_group) (__dotfiles_ll_flags $s) --color=always $HOME 2>/dev/null | sed 's/^/    /'
        end

        set -e STARSHIP_STYLE_PREVIEW
        set -e STARSHIP_COLOR_PREVIEW
        __dotfiles_rebuild_quiet
    else
        echo "  $heading""ls styles$normal $muted(install eza to see previews)$normal"
        for s in 1 2 3 4 5 6
            set -l mkr (__dotfiles_active_marker $s $saved_ls)
            echo "  $mkr$s "(__dotfiles_ls_style_preview $s)
        end

        echo ""
        echo "  $heading""ll styles$normal $muted(install eza to see previews)$normal"
        for s in 1 2 3 4 5 6
            set -l mkr (__dotfiles_active_marker $s $saved_ll)
            echo "  $mkr$s "(__dotfiles_ll_style_preview $s)
        end
    end

    echo ""
    echo "$heading""ls group$normal"
    if test "$saved_lsgrp" = on
        echo "  "(set_color green)"*"(set_color normal)"on   --group-directories-first"
        echo "   off  (default, no grouping)"
    else
        echo "   on   --group-directories-first"
        echo "  "(set_color green)"*"(set_color normal)"off  (default, no grouping)"
    end
end
