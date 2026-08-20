# Personal

Skills tied to my own setup — hard-coded paths, personal accounts, or a single
machine's workspace layout. Deliberately **not promoted**: they carry no entry in
the top-level `README.md` or `.claude-plugin/plugin.json`, so `npx skills add` will
never offer them. They still sync through git and are picked up by `npm run link`.

## Model-invoked

Reachable by the agent on its own, or by name.

- **[fetch-clickup-tasks](./fetch-clickup-tasks/SKILL.md)** — Fetch my TO-DO ClickUp tasks and render them as a table, delegating the API calls to a Haiku sub-agent.
- **[research-works](./research-works/SKILL.md)** — Collect data points for a portfolio `Work` entry by scraping a live site, browsing a remote repo, or reading a local project directory.
