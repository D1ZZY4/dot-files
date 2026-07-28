function __dotfiles_status
    set -l repo (__dotfiles_repo_path)
    if test -z "$repo"
        echo "Installed via copy or unknown source. Cannot determine status."
        return 0
    end

    set -l dirty 0
    set -l branch_info (git -C "$repo" symbolic-ref --short HEAD 2>/dev/null; or echo "detached")
    echo "Repo: $repo"
    echo "Branch: $branch_info"

    set -l modified (git -C "$repo" diff --name-only 2>/dev/null)
    if test (count $modified) -gt 0
        echo "Modified files:"
        for f in $modified
            echo "  M $f"
        end
        set dirty 1
    else
        echo "No modified files."
    end

    set -l untracked (git -C "$repo" ls-files --others --exclude-standard config/ 2>/dev/null)
    if test (count $untracked) -gt 0
        echo "Untracked files under config/:"
        for f in $untracked
            echo "  ? $f"
        end
        set dirty 1
    end

    set -l ahead (git -C "$repo" rev-list --count "@{upstream}..HEAD" 2>/dev/null; or echo 0)
    set -l behind (git -C "$repo" rev-list --count "HEAD..@{upstream}" 2>/dev/null; or echo 0)
    if test "$ahead" -gt 0; or test "$behind" -gt 0
        echo "Ahead $ahead, behind $behind."
        set dirty 1
    else
        echo "Installed dotfiles are up to date."
    end

    return $dirty
end
