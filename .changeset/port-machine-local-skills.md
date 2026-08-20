---
"gilead-skills": minor
---

Port nine machine-local skills into the repo so they sync across machines.

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
