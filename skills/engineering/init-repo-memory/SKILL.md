---
name: init-repo-memory
description: Initialize or revise repository memory files for persistent AI project context, including optional multi-agent coordination setup.
---

# Initialize repository memory

Create useful project memory in the requested repository. Inspect existing instructions and relevant project configuration before choosing files. Preserve project facts, user decisions, and existing release conventions.

For ordinary setup, use [references/memory-files.md](references/memory-files.md). Create only files that serve the request; an empty repository does not need a complete documentation system. If the user explicitly asks for a named set of files, create that set.

For a requested multi-agent setup, also read [references/multi-agent.md](references/multi-agent.md). Ordinary initialization does not authorize installing agents, hooks, editor settings, or global configuration.

For an audit of existing AGENTS.md or CLAUDE.md instructions, use /audit-agent-instructions when available; otherwise review them against the criteria below. Apply requested improvements while preserving unrelated content.

## Writing criteria

Keep always-loaded instructions project-specific. Route readers to documents when their subject is relevant. Specify completion and actual permission boundaries without mandatory startup ceremonies or repeated generic testing advice. Do not assume every future agent uses the same model.

Record verified commands with their working directory and purpose. Do not claim tests are isolated or production-free unless configuration supports that claim. Treat unknown commands or environment details as unresolved, not invented setup facts.

Retain real architectural constraints and the reasons behind them. Current user instructions can revise prior decisions; record supersession instead of declaring every historical choice permanently frozen. Record durable changes when they occur, not mandatory edits to every memory file after every session.

## Completion

Check that generated links resolve, commands match project configuration, and facts agree across files. Remove unused template sections. Report created or revised files, material preserved constraints, and any unverified setup details. Do not claim another harness loads a file automatically without verifying its configuration or documentation.

Basis: [OpenAI's September 2026 guidance](https://developers.openai.com/blog/rethinking-skills-and-prompts-for-gpt-6-astra). These defaults are adaptable to the project's agents and workflows.
