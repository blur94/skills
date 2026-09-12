# Optional multi-agent memory

Read only when the user requests multi-agent coordination setup. Setting up documentation is distinct from launching agents to execute project work.

Use the project's existing roles and orchestration choices. If the user requests the CEO/HR/Researcher/Worker/QA workflow, document that choice and use /ceo-pipeline when available for subsequent execution. Do not silently substitute that workflow for ordinary solo work or invoke it just to initialize files.

For that workflow, keep the names its consumers expect:

- AGENTS.md: Agent Registry with agent name, definition location, specialization, last use, and measured review outcomes; use pending where unknown. Keep Agent Org Protocol brief and scoped to delegated tasks.
- PLAN.md: Current Task and Active Agents, including phase ownership, dependencies, acceptance criteria, and status.
- DECISIONS.md: Agent Routing Decisions recording the user's chosen coordination approach and why.
- CONTRACTS.md: Shared agreements referenced by producing and consuming phases; link canonical types when available.

Assign one owner per shared file. Define interfaces before dependent implementation; parallelize only independent work supported by the actual harness. Avoid claims that all subagents lack communication or that a particular framework requires a particular agent arrangement.

If agent installation is explicitly requested, inspect the target harness's supported format and installed definitions. Prefer existing agents. Do not overwrite customized definitions or install globally merely because repository setup was requested. Global hooks and editor configuration require their own requested scope; they are not memory files.
