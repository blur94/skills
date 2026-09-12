# Choosing memory files

| File | Create or extend when | Content |
| --- | --- | --- |
| AGENTS.md | Persistent agent guidance is requested | Verified workflow commands, non-obvious constraints, relevant documentation pointers |
| CLAUDE.md | Claude support is requested or already present | A reference to shared guidance and only Claude-specific differences |
| PLAN.md | Work must resume across sessions or a plan is requested | Objective, acceptance criteria, current progress, blockers, next action |
| DECISIONS.md | Decisions need durable rationale | Decision, reason, implications, date, status, and replacement link if superseded |
| CHANGELOG.md | A change history is requested | Follow the existing release process; do not replace a generated changelog or changesets |
| CONTRACTS.md | Multiple components need an agreement not already captured in code | Producer, consumers, canonical schema location, invariants, status |

A plain initialization request normally starts with AGENTS.md. Add other files when the project and request justify them. Prefer links to canonical schemas and ADRs over copying their contents. For a requested empty file, use a meaningful title and explain that no entries exist yet; do not fabricate decisions or progress.

For CLAUDE.md, preserve any existing import arrangement. A prose instruction to consult AGENTS.md can share guidance without assuming every harness supports the same import syntax. Verify harness-specific imports before introducing them.

When updating an existing setup, trace incoming references before moving or removing sections. Preserve release history and handoff information. Do not delete existing files just because the new default would not create them.
