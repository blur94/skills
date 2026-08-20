#!/usr/bin/env bash
set -euo pipefail

# Links all skills in the repository to ~/.claude/skills, so that
# they can be used by the local Claude CLI.

REPO="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$HOME/.claude/skills"

# If ~/.claude/skills is a symlink that resolves into this repo, we'd end up
# writing the per-skill symlinks back into the repo's own skills/ tree. Detect
# and bail out instead of polluting the working copy.
if [ -L "$DEST" ]; then
  resolved="$(readlink -f "$DEST")"
  case "$resolved" in
    "$REPO"|"$REPO"/*)
      echo "error: $DEST is a symlink into this repo ($resolved)." >&2
      echo "Remove it (rm \"$DEST\") and re-run; the script will recreate it as a real dir." >&2
      exit 1
      ;;
  esac
fi

# Git Bash's `ln -s` silently copies the directory instead of linking unless
# Developer Mode is on, which leaves stale duplicates that never see repo edits.
# Directory junctions need no privileges and behave like symlinks to bash, so
# use those on Windows.
case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*) WINDOWS=1 ;;
  *)                    WINDOWS=0 ;;
esac

link() {
  local src="$1" target="$2"
  if [ "$WINDOWS" -eq 1 ]; then
    cmd //c mklink //J "$(cygpath -w "$target")" "$(cygpath -w "$src")" >/dev/null
  else
    ln -sfn "$src" "$target"
  fi
}

mkdir -p "$DEST"

find "$REPO/skills" -name SKILL.md -not -path '*/node_modules/*' -not -path '*/deprecated/*' -print0 |
while IFS= read -r -d '' skill_md; do
  src="$(dirname "$skill_md")"
  name="$(basename "$src")"
  target="$DEST/$name"

  # Removing a link removes only the link; removing a real dir removes its
  # contents, which is intended -- the repo is the source of truth.
  rm -rf "$target"

  link "$src" "$target"

  if [ ! -L "$target" ]; then
    echo "error: $target is not a link -- refusing to leave a stale copy behind." >&2
    exit 1
  fi
  echo "linked $name -> $src"
done
