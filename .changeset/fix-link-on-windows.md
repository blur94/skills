---
"gilead-skills": patch
---

Fix `npm run link` silently copying instead of linking on Windows.

Git Bash's `ln -s` falls back to a recursive directory copy unless Developer Mode
is enabled, so `~/.claude/skills/<name>` became a stale duplicate that never saw
repo edits — the opposite of the live edit loop the script advertises. The script
now creates directory junctions on Windows (no privileges required, and bash reads
them as symlinks) and asserts the result is a link before reporting success.
