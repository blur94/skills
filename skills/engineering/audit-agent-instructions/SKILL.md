---
name: audit-agent-instructions
description: Audit or improve AGENTS.md and CLAUDE.md files when the user requests instruction cleanup, project-memory review, or model-migration tuning.
---

# Audit agent instructions

Review instruction files against the actual project and the agents that use it. Optimize usefulness, correctness, and scope rather than minimizing word count or filling a template.

## Scope and evidence

Use the requested repository or named projects. If no target is evident, ask for the location. Audit each project separately; do not search the entire machine. Discover root and nested AGENTS.md and CLAUDE.md files, including relevant hidden configuration and local variants. Exclude dependencies, generated output, and version-control internals. Report discovery exclusions or incomplete coverage.

Read applicable parent instructions and follow relevant imports or links. Note each file's scope and audience. Resolve symlinks before proposing edits and identify shared targets. Do not assume AGENTS.md and CLAUDE.md have identical loading or precedence rules; verify uncertain harness behavior before changing an import arrangement. Global instructions may explain conflicts but are outside repository-edit scope unless requested.

Inspect enough configuration, scripts, CI, and relevant code to verify disputed instructions. Distinguish documented intent from observed behavior. Do not run deploy, migration, or external-effect commands just to verify their names.

## Assessment

For each actionable finding, identify the file and line, evidence, effect on agent behavior, and proposed correction:

- Correct stale paths and commands using project evidence; label anything unverified.
- Resolve contradictory or duplicated instructions with attention to directory scope and different agent audiences.
- Replace blanket document-reading requirements with subject-specific pointers where appropriate.
- Remove generic coaching or obsolete workarounds only when they add no demonstrated value. Preserve real safety, compatibility, compliance, and team requirements.
- Distinguish useful validation commands from repeated mandates that cause redundant checks.
- Clarify completion and permission boundaries without extending authorization. Never infer production isolation from a test filename.
- Move substantial specialist procedures into linked documentation only when a future reader can still discover them. Do not create skills, hooks, or agent teams as an incidental audit fix.

Do not treat shorter files or absent standard headings as evidence of quality. Keep recommendations compatible with the models the project actually uses; note tradeoffs if unknown.

## Report and changes

An audit-only request produces findings and concrete proposed replacements without editing. A request to fix, improve, or apply changes authorizes targeted local edits: present the findings first, then apply within that scope. Ask only when a material policy choice cannot be resolved from the request and evidence. Preserve user edits and unrelated sections.

Check changed links, commands against configuration, and overlapping instructions after editing. Report what was verified, remaining uncertainty, and any behavior that still needs a real task evaluation. A static audit is not proof of optimal agent performance.

Use a compact file-by-file report: scope, finding, evidence, recommended or applied change, and validation. Avoid arbitrary numeric scores. If nothing warrants changing, say so.

Basis: [OpenAI's instruction-maintenance guidance](https://developers.openai.com/blog/rethinking-skills-and-prompts-for-gpt-6-astra). The evidence-first report also draws on the claude-md-management workflow; this skill works without that plugin installed.
