# Skills

My agent skills, installable into Claude Code and other coding agents.

## Install

```bash
npx skills@latest add blur94/skills
```

Pick the skills you want and the agents to install them on.

## Skills

### Engineering

Daily code work. Model-invoked — the agent reaches for these on its own when the work matches.

- **[building-walkthroughs](./skills/engineering/building-walkthroughs/SKILL.md)** — Build or replicate an onboarding tour, feature spotlight, or coach-mark sequence, anchored to the target app's real UI and user goals rather than to pixels.
- **[good-ux-auditor](./skills/engineering/good-ux-auditor/SKILL.md)** — Audit a product against 16 Good UX heuristics: the four states, loader psychology, error message anatomy, form friction, and progressive disclosure.
- **[init-repo-memory](./skills/engineering/init-repo-memory/SKILL.md)** — Set up a repository's persistent AI memory — `AGENTS.md`, `CLAUDE.md`, `PLAN.md`, `DECISIONS.md`, `CHANGELOG.md` — optionally wired for a multi-agent org.
- **[pr-description](./skills/engineering/pr-description/SKILL.md)** — Write PR titles and bodies in a fixed house format: imperative title, what/where/why summary, themed sections with action-verb bullets, and a closing impact statement.
- **[prisma-v7-workflow](./skills/engineering/prisma-v7-workflow/SKILL.md)** — Make Prisma v7 schema changes, migrations, and client generation without tripping the breaking changes carried over from v5/v6.
- **[react-doc-viewer-integration](./skills/engineering/react-doc-viewer-integration/SKILL.md)** — Add `react-doc-viewer` to a React or Next.js app: one reusable `<DocumentViewer>`, the PDF/image renderer override, authenticated URLs, and Jest mocking.
- **[temporal-api](./skills/engineering/temporal-api/SKILL.md)** — Quick reference for the JavaScript Temporal API: class selection, conversions, arithmetic, timezones, and calendars.

### Misc

Kept around but rarely reached for. Model-invoked.

- **[ceo-pipeline](./skills/misc/ceo-pipeline/SKILL.md)** — Run the CEO→HR→Researcher→Worker→QA multi-agent pipeline, enforcing contract pre-negotiation, dependency ordering, and decomposition before any implementation. Ships the four agent definitions it spawns in `ceo-pipeline/agents/`.

Skills under `skills/personal/` are tied to my own setup and are deliberately not
listed here or in the plugin manifest — see [skills/personal/README.md](./skills/personal/README.md).

## Local development

Symlink every skill in this repo into `~/.claude/skills`, so edits here are live
in your local agent without reinstalling:

```bash
npm run link
```

List what the repo currently ships:

```bash
npm run list
```

## Releasing

Versioned with [changesets](https://github.com/changesets/changesets). Add one
alongside any skill change:

```bash
npm run changeset
```

Pushing to `main` opens a version PR; merging it tags the release.

## Conventions

See [CLAUDE.md](./CLAUDE.md) for the bucket layout and the rules every skill
follows, and [docs/invocation.md](./docs/invocation.md) for the difference
between user-invoked and model-invoked skills.

## Credit

This repository began as a fork of [mattpocock/skills](https://github.com/mattpocock/skills).
His skills have been removed — install them from his repo directly:

```bash
npx skills@latest add mattpocock/skills
```

The repository scaffolding (bucket conventions, changesets release flow, and the
`scripts/` helpers) originates from that project and is used here under its MIT
licence.

## Licence

MIT — see [LICENSE](./LICENSE).
