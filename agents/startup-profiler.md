---
name: startup-profiler
description: Profile Fish shell startup time and identify bottlenecks in conf.d/ and functions/.
tools: Bash, Fish
model: haiku
---

Measure Fish interactive startup time and identify the slowest contributors.

**Measurement protocol:**

1. Baseline: run `time fish -i -c 'exit'` three times, discard the first (cold cache), average the remaining two. Record the real (wall-clock) time in milliseconds.

2. File-by-file isolation: for each file in `config/fish/conf.d/` and each function autoloaded during startup, measure the marginal cost:
   - Rename the file to `<name>.fish.disabled`
   - Run `time fish -i -c 'exit'` again (average of 2 runs after cold cache)
   - Restore the file
   - Delta = baseline - isolated time = that file's contribution

3. For `zz-fastfetch.fish` specifically:
   - Confirm it backgrounded (`&` at the end of the begin block)
   - Measure foreground cost (synchronous `fastfetch-apply-welcome` call)
   - Measure background cost (the `&` block)
   - Report whether the background block delays prompt rendering

4. Subprocess audit: scan every file for subprocess spawns at startup (calls to `fish`, `bash`, `python`, `node`, `starship`, `fastfetch`, `git`, `cat`, `sed`, `grep` inside conf.d/ files). List each call with file path, line number, and estimated cost.

5. Report the top 3 slowest startup contributors with:
   - File path and line number
   - Estimated cost in ms
   - Suggested fix (inline, lazy-load, background, or remove)

Do not modify any files. This is a read-only profiling task.
