# Skills

My agent skills, installable into Claude Code and other coding agents.

## Install

```bash
npx skills@latest add blur94/skills
```

Pick the skills you want and the agents to install them on.

## Skills

### Engineering

Model-invoked — the agent reaches for these on its own when the work matches.

- **[pr-description](./skills/engineering/pr-description/SKILL.md)** — Write PR titles and bodies in a fixed house format: imperative title, what/where/why summary, themed sections with action-verb bullets, and a closing impact statement.

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
