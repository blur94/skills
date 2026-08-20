# gilead-skills

## 1.1.0

### Minor Changes

- [`06182cc`](https://github.com/blur94/skills/commit/06182cc80326f1298a967514a201927f9f75a2bd) Thanks [@blur94](https://github.com/blur94)! - Port nine machine-local skills into the repo so they sync across machines.

  `engineering/` gains `building-walkthroughs`, `good-ux-auditor`, `init-repo-memory`,
  `prisma-v7-workflow`, `react-doc-viewer-integration`, and `temporal-api`. `misc/` gains
  `ceo-pipeline`, which now ships the four agent definitions it spawns (`ceo`, `hr`,
  `researcher`, `qa`) in `ceo-pipeline/agents/` — previously they lived only in
  `~/.claude/agents/`, so a ported copy of the skill would have failed on every spawn.

  Adds a `personal/` bucket for `fetch-clickup-tasks` and `research-works`, which
  hard-code this machine's paths and accounts. Per the bucket conventions they are
  excluded from `README.md` and `.claude-plugin/plugin.json`, so they sync through git
  without being offered by `npx skills add`.

  Drops the "Sync rule" headers from `ceo-pipeline` and `init-repo-memory`. Those
  instructed the agent to hand-mirror each file between `~/.claude/skills` and
  `~/.agents/skills`; the repo is now the single source of truth and `npm run link`
  does the mirroring.

### Patch Changes

- [`2fab0a9`](https://github.com/blur94/skills/commit/2fab0a907b0c36d739b7806343ffe78d5a8e20b7) Thanks [@blur94](https://github.com/blur94)! - Fix `npm run link` silently copying instead of linking on Windows.

  Git Bash's `ln -s` falls back to a recursive directory copy unless Developer Mode
  is enabled, so `~/.claude/skills/<name>` became a stale duplicate that never saw
  repo edits — the opposite of the live edit loop the script advertises. The script
  now creates directory junctions on Windows (no privileges required, and bash reads
  them as symlinks) and asserts the result is a link before reporting success.

## 1.0.0

Initial release of this repository as a standalone skills collection.

Forked from [mattpocock/skills](https://github.com/mattpocock/skills), whose
skills have since been removed — install those from his repo directly. The
release tooling and bucket conventions carried over from that project.

### Skills

- **`pr-description`** — Writes PR titles and bodies in a fixed house format:
  imperative title capped at 72 characters, a what/where/why summary paragraph,
  level-3 themed sections with action-verb bullets naming concrete files, an
  explicit UI-impact statement when UI changes, and a closing impact statement.
