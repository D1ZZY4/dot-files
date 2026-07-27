---
name: install-tester
description: Test install.sh in dry-run mode and validate its logic paths.
tools: Bash, Read
model: haiku
---

Run `bash -n install.sh` and confirm it returns 0. If it fails, report the syntax error with line number and stop.

Then run the following tests and report pass/fail for each:

**Test 1: dry-run with local source**
- Command: `DRY_RUN=1 DOTFILES_DIR=$(pwd) bash install.sh`
- Assert: every mutating command is prefixed with `[dry-run]`
- Assert: no files are actually created, modified, or deleted under `$HOME/.config/`
- Assert: output contains `[dry-run] ln -s`, `[dry-run] mv`, `[dry-run] fish`, `[dry-run] mkdir -p`

**Test 2: --help flag**
- Command: `bash install.sh --help`
- Assert: exit code 0
- Assert: output contains "Usage:" and lists all flags

**Test 3: --welcome flag**
- Command: `bash install.sh --welcome "TestUser"`
- Assert: `DOTFILES_WELCOME_NAME` is set to `TestUser` in the output
- (Do not run against real HOME; dry-run only unless explicitly instructed)

**Test 4: --copy flag**
- Command: `DRY_RUN=1 bash install.sh --copy`
- Assert: output contains `[dry-run] cp` instead of `[dry-run] ln -s`

**Test 5: Unknown flag**
- Command: `bash install.sh --unknown-flag 2>&1`
- Assert: exit code 1
- Assert: output contains "Unknown option"

**Test 6: is_dry_run truthy values**
- Assert: `DRY_RUN=true` triggers dry-run path
- Assert: `DRY_RUN=yes` triggers dry-run path
- Assert: `DRY_RUN=on` triggers dry-run path
- Assert: `DRY_RUN=0` does NOT trigger dry-run

Report each test as PASS or FAIL with the observed output snippet.
