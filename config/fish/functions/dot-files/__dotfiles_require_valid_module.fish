function __dotfiles_require_valid_module --argument-names module_name
    if test -z "$module_name"
        echo "dot-files: missing module name" >&2
        echo "Available: "(string join ' ' (__dotfiles_all_modules)) >&2
        return 1
    end
    if not contains -- "$module_name" (__dotfiles_all_modules)
        echo "dot-files: unknown module '$module_name'" >&2
        echo "Available: "(string join ' ' (__dotfiles_all_modules)) >&2
        return 1
    end
end
