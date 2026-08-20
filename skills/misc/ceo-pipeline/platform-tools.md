# Platform Tool Reference

How to spawn HR on each platform. Fill in the placeholders and send.

---

## Claude Code

Use the `Agent` tool. Set `subagent_type: "hr"` if `hr.md` exists in `~/.claude/agents/`.

```javascript
Agent({
  description: "HR: read registry, assign agents to all task phases",
  subagent_type: "hr",
  prompt: `
You are HR. The CEO has decomposed a task and written phases to PLAN.md.

Read these files first — in order:
1. AGENTS.md → Agent Registry (who exists, QA pass rates)
2. DECISIONS.md → Agent Routing Decisions (parallel sub-agents vs Agent Teams, escalation trigger)
3. CONTRACTS.md → shared interfaces workers must read before implementing (if present)
4. PLAN.md → Current Task (phases are already written here with depends_on and contracts fields)

Original task (verbatim):
[PASTE TASK DESCRIPTION]

Phases:
1. [Phase name] — [scope]
   Depends on: [Phase X | none]
   Contracts: [entries to read/write | none]
   Acceptance criteria: [criteria]

2. [Phase name] — [scope]
   Depends on: [Phase X | none]
   Contracts: [entries to read/write | none]
   Acceptance criteria: [criteria]

Before spawning workers, run this cost checklist:
- [ ] Can any phases be batched into one worker without quality loss?
- [ ] Is each worker's context trimmed to only what it needs?
- [ ] Are mechanical phases (isolated, well-specified) using a cheaper model?

Your steps:
1. Spawn Researcher with the full phase list — get fit scores (1–5) for existing agents per phase
2. Employ agents scoring ≥ 4; commission new ones from Researcher's spec for gaps
3. Assign each worker: scope + tools they may use + contracts to read + acceptance criteria
4. Spawn independent phases in parallel using the Agent tool
5. Spawn phases with depends_on only after their dependency reaches approved
6. Update PLAN.md → Active Agents with each worker's status
7. When all workers reach review_requested, spawn QA with the original task spec
  `
})
```

After spawning HR, wait. Do not spawn Researcher, workers, or QA yourself.

---

## Codex

Use the `Task` delegation primitive:

```
Task("HR: read registry, assign agents to all task phases", `
  [same prompt body as above]
`)
```

If your Codex version does not support `Task`, open a new Codex session and paste the HR prompt as the first message. Point it at `AGENTS.md`, `DECISIONS.md`, `CONTRACTS.md`, and `PLAN.md`.

---

## GitHub Copilot

Copilot Chat does not support programmatic agent spawning. Use this manual session sequence:

**Session 1 — HR**

Open a new Copilot Chat. Paste as your first message:

```
Act as HR. Read in order: AGENTS.md → Agent Registry, DECISIONS.md → Agent Routing Decisions, CONTRACTS.md (if present), PLAN.md → Current Task.

Original task: [paste task]

Phases:
1. [Phase] — [scope]
   Depends on: [Phase X | none]
   Contracts: [entries | none]
   Acceptance: [criteria]

Run the cost checklist (batch? trim context? cheaper model for mechanical tasks?).
For each phase: score existing agents for fit. Employ ≥ 4; draft a spec for gaps.
List which agent handles which phase and their depends_on order.
Update PLAN.md → Active Agents.
```

**Sessions 2+ — Workers**

For each assigned worker, open a separate Copilot Chat. Give it only:
- Its scope
- Which tools it may use
- Which CONTRACTS.md entries to read
- Its acceptance criteria

Use `superpowers:subagent-driven-development` within each worker session for spec + quality review gates.

**Final session — QA**

Open one Copilot Chat. Point QA at `PLAN.md` → Current Task and each worker's output.
QA checks acceptance criteria per phase. Flags rework before you synthesize.

---

## What workers need from HR

Every worker must receive:
- Exact scope (one sentence, no ambiguity)
- Tools it may use (do not leave this open-ended)
- CONTRACTS.md entries it must read before starting
- Acceptance criteria (what QA will verify)
- Relevant file paths only — not the whole codebase

Workers use `superpowers:subagent-driven-development` for implementation with two-stage review gates.
