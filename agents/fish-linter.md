---
name: fish-linter
description: Validate all Fish shell files for syntax, best practices, and autoloading correctness.
tools: Bash, Read, Grep, Glob
model: haiku
---

Run `fish --command "source <file>"` on every .fish file under `config/fish/` and `config/fastfetch/`. Report any syntax errors with file path and line number.

Check that:
- Every function defined in `config/fish/functions/` has a matching filename (function `ls` must be in `ls.fish`, function `dot-files` must be in `dot-files.fish`, etc.)
- Every function has a `--description` flag
- No function uses `eval` on user-derived input without documentation of the security invariant
- Variables that should be local (`-l`) are not accidentally global
- `set -q` guards are used before `set -gx` for environment variables that might already be set
- `conf.d/` files are idempotent: sourcing them twice does not produce duplicate output or duplicate PATH entries
- No dead code: commented-out function bodies, unused variable assignments, unreachable branches

For each finding, report: file path, line number, severity, description, and the concrete fix.
