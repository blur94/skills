---
name: init-repo-memory
description: >
  Sets up a persistent AI collaboration and project memory system for a repository
  by creating five structured markdown files: AGENTS.md, CLAUDE.md, PLAN.md,
  DECISIONS.md, and CHANGELOG.md. Use this skill whenever the user wants to start a
  new project, set up AI-assisted development, initialize repo memory, prepare a
  codebase for Claude Code or Cursor, track architectural decisions, or says anything
  like "set up my repo for AI", "initialize my project memory", "prepare this repo
  for Claude", "I want to track decisions", or "set up collaboration files". Also
  trigger when the user starts a new project from scratch and hasn't set up any
  project tracking yet. Also use when the user asks to upgrade an existing repo memory
  system to support a multi-agent org, add an agent registry, set up CEO/HR/Worker/QA
  agent roles, or wire routing rules for sub-agents and agent teams.
---

# Initialize Repo Memory System

This skill creates five durable, repo-native files that give AI agents (and engineers)
a persistent source of truth that survives across sessions, tools, and chat history.

The core idea: **the repository should describe itself**. Future AI sessions should
be able to continue work by reading these files alone — no chat history required.

The files also wire directly into a self-organizing multi-agent org: a CEO, HR,
Researcher, Worker, and QA agent hierarchy that can decompose, delegate, execute,
and verify work autonomously across sessions.

---

## Step 1: Determine target directory

Ask the user where to create the files if it's not clear from context. This is usually
the project root. If they say "here" or "this folder", use the current working directory
or their connected workspace folder.

If a workspace folder is connected, save files there so the user can open them directly.

---

## Step 2: Check for existing files

Before writing anything, check if any of the six files already exist:

- `AGENTS.md`
- `CLAUDE.md`
- `PLAN.md`
- `DECISIONS.md`
- `CHANGELOG.md`
- `CONTRACTS.md`

If a file exists:
- Read it first
- Preserve any project-specific content already there
- Merge intelligently — normalize formatting, fill in missing sections, don't overwrite good content
- Tell the user what you're preserving vs. adding

If no files exist, create all five from scratch using the templates below.

---

## Step 3: Create the files

Create all six files. Use the exact structure described below.

---

### AGENTS.md

Universal AI collaboration instructions. Tool-agnostic — works with Claude Code, Cursor,
Windsurf, ChatGPT, and any future coding agent.

```markdown
# AGENTS.md
Universal AI collaboration instructions for all coding agents (Claude Code, Cursor, Windsurf, ChatGPT, etc.).

---

## Startup Protocol

> **STOP. Do not write code, answer questions, or take any action until this protocol is complete.**
> Skipping any step is a protocol violation regardless of how simple the task appears.

**Step 1 — Identify your role** (multi-agent sessions only): Are you acting as CEO, HR, Researcher, Worker, or QA? Read `Agent Org Protocol` below. Declare your role explicitly before proceeding.

**Step 2 — Read these files in order:**

1. `PLAN.md` — current project state and active tasks
2. `DECISIONS.md` — frozen architectural and product decisions
3. `CHANGELOG.md` — completed work history
4. `CONTRACTS.md` — shared interfaces and contracts (read before implementing if present)

**Step 3 — Summarize**: Write one paragraph stating your understanding of the current project state and what needs to be done next. This is mandatory — it confirms you read the files and did not skip ahead.

---

## File Responsibilities

| File | Purpose |
|------|---------|
| `PLAN.md` | Active working memory — what is being built right now |
| `DECISIONS.md` | Frozen decisions — things that are settled and should not change |
| `CHANGELOG.md` | Historical record — completed implementation work |
| `CONTRACTS.md` | Shared interfaces, API contracts, event payloads, naming conventions, state invariants — workers read before implementing, write when defining new contracts |

---

## Core Behavioral Rules

- **Never override frozen decisions** in `DECISIONS.md` unless the user explicitly instructs you to.
- **Keep implementation consistent** with existing architecture described in `DECISIONS.md`.
- **Prefer incremental changes** over full rewrites. If a rewrite is necessary, flag it explicitly and ask first.
- **Avoid assumptions from previous chats**. The repo files are the source of truth, not conversation history.
- **Remove completed tasks** from `PLAN.md` after they are done. Do not let it accumulate stale entries.
- **Do not invent requirements**. If something is unclear, ask before implementing.
- **Prefer typed, explicit, maintainable code** over clever or terse shortcuts.
- **(React) Never silence a `useEffect` dependency warning with `eslint-disable-next-line react-hooks/exhaustive-deps`.** If an effect must read a value without re-running when that value changes, use `useEffectEvent` (or the project's equivalent escape hatch) instead of omitting the value from the deps array. This isn't a style preference — omitting-and-disabling is a common source of stale closures and infinite render loops in practice (any non-memoized object recreated every render, e.g. the object returned by `@mantine/form`'s `useForm()`, will retrigger the effect on every render if included in deps, or silently go stale if excluded without `useEffectEvent`).

---

## End-of-Session Workflow

At the end of every implementation session, update the following files:

### PLAN.md
- Remove tasks that were completed
- Update the status/context of in-progress work
- Add any newly discovered tasks or complications

### DECISIONS.md
- Record any new architectural or product decisions that were made
- Include the date, decision, reasoning, and implications

### CHANGELOG.md
- Record completed implementation work under `## Unreleased`
- Use developer-facing, concise language

---

## What Belongs Where

**In PLAN.md:** what you're building right now, acceptance criteria, deferred ideas (Parking Lot section)

**In DECISIONS.md:** technology choices, structural patterns, anything you'd explain to a new engineer joining the project

**In CHANGELOG.md:** features added, bugs fixed, things changed or removed, completed milestones

**In CONTRACTS.md:** shared TypeScript interfaces, API request/response shapes, event payloads, naming conventions, state invariants — anything two or more workers must agree on before implementing

**Not in any file:** temporary debug notes, speculative ideas (use Parking Lot in PLAN.md instead)

---

<!-- ═══════════════════════════════════════════════════════════════
     MULTI-AGENT ORG UPGRADE
     The sections below extend this file for use with a self-organizing
     multi-agent org (CEO → HR → Researcher → Worker → QA).
     ═══════════════════════════════════════════════════════════════ -->

## Agent Registry

**HR must read this table before employing any agent.**
**Researcher must check this table before drafting a spec for a new agent.**

If an agent already exists that fits the task, use it. Commission a new one only
when no existing agent scores adequately for fit against the current task.

| Agent | File | Specialization | Last Used | QA Pass Rate |
|-------|------|---------------|-----------|-------------|
| _No agents registered yet. HR populates this table after the first session._ | | | | |

> New agent definitions are written by HR to `.claude/agents/`, not into this file.
> HR updates this table after every session with the agent's last-used date and QA pass rate.

---

## Agent Org Protocol

This section describes the multi-agent org structure for this repository.
All agents must read this section at session start before beginning any work.

### Roles and Responsibilities

**CEO**
- Receives the task from the engineer.
- Decomposes it into phases and delegates each phase to HR.
- Synthesizes the final output from QA-approved worker outputs.
- Never implements directly.
- Reads: `PLAN.md`, `DECISIONS.md`. Writes: `PLAN.md` (task decomposition).

**HR Agent**
- Reads the Agent Registry above before making any hiring decision.
- Consults Researcher to assess which existing agents fit the task and which gaps exist.
- Employs existing agents or commissions new ones based on Researcher's scoring.
- Assigns each agent an explicit scope, toolset, and success criteria.
- Writes new agent definitions to `.claude/agents/` on demand.
- Updates the Agent Registry (above) after every session.
- Reads: `AGENTS.md` (registry + protocol), `DECISIONS.md` (routing rules), `PLAN.md`.
- Writes: `AGENTS.md` (registry), `.claude/agents/` (new agent definitions), `PLAN.md` (active agents section).

**Researcher Agent**
- Audits the codebase and the Agent Registry before HR makes any hiring decision.
- Scores existing agents for fit against the current task.
- If no agent fits, drafts a spec for a new one and hands it to HR.
- Reads `CHANGELOG.md` to understand patterns already established in this codebase.
- Reads: `AGENTS.md` (registry), `CHANGELOG.md`, `DECISIONS.md`, relevant codebase files.
- Writes: agent specs (handed to HR; not committed directly to the registry).

**Worker Agents**
- Spawned by HR. Definitions live in `.claude/agents/`.
- Either pre-existing or written on demand by HR based on Researcher's spec.
- Execute in parallel (sub-agents) or with peer coordination (Agent Teams) per the routing rules in `DECISIONS.md`.
- Reads: assigned scope from HR, relevant codebase files.
- Writes: implementation output within their assigned scope only.

**QA Agent**
- Reviews worker output against the original task spec before CEO synthesizes.
- Flags rework to HR if output does not meet acceptance criteria.
- Updates the QA Pass Rate column in the Agent Registry after each review.
- Only passes work to CEO when all outputs meet acceptance criteria.
- Reads: original task spec (`PLAN.md`), worker outputs.
- Writes: `AGENTS.md` (pass rates), `CHANGELOG.md` (completed task summaries at end-of-session).

### Escalation Path

1. HR assigns workers as parallel sub-agents (default).
2. If the escalation trigger is met (see `DECISIONS.md` → Agent Routing Decisions), HR switches to Agent Teams for the affected phases.
3. QA reviews all worker outputs before passing to CEO.
4. CEO synthesizes and delivers to the engineer.
5. HR updates the Agent Registry. QA writes the session summary to `CHANGELOG.md`.
```

---

### CLAUDE.md

Claude Code-specific orchestration layer. Supplements AGENTS.md with Claude-specific rules.

```markdown
# CLAUDE.md
Claude Code-specific orchestration instructions. These supplement and extend `AGENTS.md`.

---

## Startup Sequence

1. Read `AGENTS.md` first — it contains the universal rules all agents follow
2. Read `PLAN.md`, `DECISIONS.md`, `CHANGELOG.md`
3. Write a one-paragraph summary of the current project state and what needs to be done next
4. Only then begin implementation

---

## Before Writing Any Code

- Confirm you understand the current task from `PLAN.md`
- Verify your planned approach does not violate any entry in `DECISIONS.md`
- If there is a conflict, stop and ask — do not work around a frozen decision silently
- State your intended approach explicitly before beginning

---

## During Implementation

- Prefer typed solutions (TypeScript over JS, typed Python, etc.)
- Keep changes incremental — commit-sized chunks where possible
- If you discover an undocumented architectural decision being made, record it immediately in `DECISIONS.md`
- If you discover new work that wasn't planned, add it to the Parking Lot in `PLAN.md`
- Never carry hidden context forward from a previous conversation — if it's not in the repo files, treat it as unknown

---

## Architecture Changes

If you believe an architectural decision needs to change:

1. Do not change it silently
2. Explicitly state: what you want to change, why, and what the impact is
3. Wait for confirmation before proceeding
4. Once confirmed, update `DECISIONS.md` with the new decision

---

## End-of-Session Checklist

After completing implementation work:

- [ ] Remove completed tasks from `PLAN.md`
- [ ] Update `PLAN.md` with current progress and any new tasks discovered
- [ ] Add any new architectural decisions to `DECISIONS.md`
- [ ] Record completed work in `CHANGELOG.md` under `## Unreleased`
- [ ] Confirm repo memory files are consistent with each other

---

## Anti-Patterns to Avoid

- Do not rely on chat history as a source of truth
- Do not make sweeping refactors without flagging them first
- Do not leave `PLAN.md` with stale completed tasks
- Do not record temporary debug work in `DECISIONS.md`
- Do not skip the startup sequence even for "small" tasks

---

## Skill routing

When the user's request matches an available skill, invoke it via the Skill tool.

Key routing rules:
- Multi-agent feature / bug / triage → invoke /ceo-pipeline
- Bugs/errors → invoke /investigate
- QA/testing → invoke /qa or /qa-only
- Code review → invoke /review
- Ship/deploy/PR → invoke /ship or /land-and-deploy

---

<!-- ═══════════════════════════════════════════════════════════════
     MULTI-AGENT ORG UPGRADE
     The sections below extend this file for use with a self-organizing
     multi-agent org (CEO → HR → Researcher → Worker → QA).
     ═══════════════════════════════════════════════════════════════ -->

## Multi-Agent Startup Sequence

When this session is part of a multi-agent org (CEO, HR, Researcher, Worker, or QA),
extend the standard startup sequence above with these additional steps — in order,
before doing any work:

1. Read `AGENTS.md` → **Agent Org Protocol** to understand the org structure and your role's responsibilities.
2. Read `AGENTS.md` → **Agent Registry** to know which agents exist, their specializations, and their QA pass rates.
3. Read `DECISIONS.md` → **Agent Routing Decisions** to understand which routing pattern applies to the current task.
4. Read `PLAN.md` → **Current Task** and **Active Agents** to understand what is being built and which agents are already assigned.
5. Determine your role for this session: CEO, HR, Researcher, a named Worker (check `.claude/agents/` for your definition), or QA.
6. Only after completing steps 1–5, begin work in that role.

Do not skip this sequence even for tasks that appear simple. Role clarity prevents duplicated work and conflicting outputs.

---

## End-of-Session Multi-Agent Checklist

After completing work in a multi-agent session, all agents must complete the following
before terminating the session:

- [ ] **Agent Registry** (`AGENTS.md`): HR updates the Last Used date for all employed agents. QA updates QA Pass Rates.
- [ ] **Changelog** (`CHANGELOG.md`): QA writes a completed task summary under `## Unreleased`. Engineers may also write here.
- [ ] **Plan** (`PLAN.md`): HR or CEO updates task status. Mark completed phases as done. QA clears the Active Agents section when the full task is complete.
- [ ] **Decisions** (`DECISIONS.md`): Any agent that encountered a new routing or architectural decision records it here, using the existing entry format (Decision, Reason, Implications).
- [ ] Confirm that all repo memory files are consistent with each other before ending the session.
```

---

### PLAN.md

Active working memory. Keep this lean — it should reflect only the current task.

```markdown
# PLAN.md
This file represents the current implementation state of the project.
It is the active working memory for all AI agents and engineers.

Keep this file lean. Remove completed work. Focus on active execution only.

---

## Frozen Section
<!-- Settled decisions currently active for implementation. -->
<!-- Link to DECISIONS.md for the full rationale. -->

_No frozen implementation constraints yet. See DECISIONS.md as it is populated._

---

## Open Section

### Current Task

**Status:** Not started

**Context:**
_Describe what this task is, why it matters, and any relevant background._

**Tasks:**
- [ ] _Add your first task here_

**Acceptance Criteria:**
- _What does "done" look like for this task?_

<!-- ═══════════════════════════════════════════════════════════════
     MULTI-AGENT ORG UPGRADE
     ═══════════════════════════════════════════════════════════════ -->

#### Active Agents

<!-- HR writes to this section when agents are assigned to the current task.      -->
<!-- QA clears this section when the task is complete and all outputs are approved. -->

| Agent | File | Assigned Scope | Status |
|-------|------|---------------|--------|
| _No agents assigned yet._ | | | |

**Status values:** `pending` · `in-progress` · `review_requested` · `needs_clarification` · `blocked` · `qa_failed` · `retrying` · `approved`

---

## Parking Lot
<!-- Future ideas or deferred work. Not prioritized yet. -->

_Nothing deferred yet._
```

---

### DECISIONS.md

Long-term architectural and product decisions. Only durable, settled decisions go here.

```markdown
# DECISIONS.md
Long-term architectural and product decisions.

Only durable decisions belong here. Avoid temporary implementation details.
Always record *why* a decision exists — not just what it is.

---

## Active Decisions

<!-- Template for new entries:

### Decision Name
**Date:** YYYY-MM-DD
**Decision:** What was decided.
**Reason:** Why this choice was made over alternatives.
**Implications:** What this means for how the codebase must be structured or maintained.

-->

_No decisions recorded yet. Add your first architectural or product decision here._

---

<!-- ═══════════════════════════════════════════════════════════════
     MULTI-AGENT ORG UPGRADE
     The section below contains frozen routing rules for the multi-agent
     org. HR must apply them as stated and must not override them without
     an explicit instruction from the engineer.
     ═══════════════════════════════════════════════════════════════ -->

## Agent Routing Decisions

### Default Routing Pattern — Parallel Sub-Agents

**Date:** _Set when repo memory was initialized_
**Decision:** Default to parallel sub-agents for all task phases where data shapes are pre-defined before work begins.
**Reason:** Sub-agents are cheaper, simpler, and sufficient when contracts between layers are already known. There is no coordination overhead and each agent can proceed independently.
**Implications:** HR must not escalate to Agent Teams unless the escalation trigger below is explicitly met. Defaulting to Agent Teams when sub-agents would suffice is a routing error.

---

### Escalation Trigger — Agent Teams

**Date:** _Set when repo memory was initialized_
**Decision:** Escalate to Agent Teams when a new API route, its consuming query hook, and its UI component are being defined in the same task and must negotiate a shared TypeScript interface before either layer can proceed.
**Reason:** Sub-agents cannot coordinate contracts peer-to-peer. When no response type exists in the codebase yet, independent workers will produce mismatched interfaces that require rework.
**Implications:** HR detects this condition by checking whether a route response type already exists in the codebase before assigning workers. If the type exists, sub-agents are sufficient. If it does not, Agent Teams are required for the affected phases only — not the entire task.

---

## Superseded Decisions
<!-- Decisions that were once active but have been replaced. -->
<!-- Move entries here (do not delete) when a decision changes, and link to the replacement. -->

_None yet._
```

---

### CHANGELOG.md

Completed work history. Follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) format.

```markdown
# CHANGELOG.md
All notable changes to this project are documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
Entries should be concise and developer-facing.

> **QA Agent responsibility:** At the end of every multi-agent session, the QA Agent
> writes completed agent task summaries under `## Unreleased`. Engineers may also write
> here directly. Do not leave completed work undocumented.

---

## Unreleased

### Added
- Initialized repo memory system (`AGENTS.md`, `CLAUDE.md`, `PLAN.md`, `DECISIONS.md`, `CHANGELOG.md`, `CONTRACTS.md`)

### Changed
_Nothing yet._

### Fixed
_Nothing yet._

### Removed
_Nothing yet._

---

<!-- Template for released versions:

## [x.y.z] - YYYY-MM-DD

### Added
### Changed
### Fixed
### Removed

-->
```

---

### CONTRACTS.md

Shared interface coordination layer. CEO defines entries here before spawning HR when phases share interfaces. Workers read before implementing and write here when defining new contracts. QA verifies implementations match.

```markdown
# CONTRACTS.md

Shared interfaces, API contracts, event payloads, naming conventions, and state invariants.

**Workers:** read the relevant sections before implementing. Write here when you define a new contract.
**QA:** verify that implementations match the entries here.
**CEO:** define contracts for any shared interfaces *before* spawning HR.

---

## How to add an entry

Use this template:

\`\`\`markdown
### [Contract name]
**Defined by:** Phase N — [phase name]
**Consumed by:** Phase M — [phase name]
**Status:** draft | stable | deprecated

[Contract body — TypeScript interface, schema, payload shape, or convention prose]
\`\`\`

---

## TypeScript Interfaces / DTOs

_No entries yet. Add here when a phase defines a shared data shape._

---

## API Contracts

_No entries yet. Add here when a phase defines a route's request/response shape._

---

## Event Payloads

_No entries yet. Add here when a phase defines an event that other phases listen to._

---

## Naming Conventions

_No entries yet. Add here when the team settles on a naming pattern workers must follow consistently._

---

## State Invariants

_No entries yet. Add here when a phase owns a state machine that other phases must respect._

---

## Superseded Contracts

_Move deprecated entries here rather than deleting them. Link to the replacement._
```

---

## Step 4: Create global org agents and per-project specialist agent directory

Agent definitions live in two tiers:

- **Org agents** (CEO, HR, Researcher, QA) → written to **both** global locations so they're available in every project across every harness
- **Specialist agents** (codebase-tuned workers) → per-project `.claude/agents/`, written by HR on demand

### 4a: Write org agent files to both global locations

Create `~/.claude/agents/` and `~/.agents/agents/` if they do not exist.
Write the four files below into **both** directories. The copies must be identical.

**Do NOT write these to the per-project `.claude/agents/` directory.** Per-project copies create stale duplicates that diverge silently from the global versions.

---

#### ceo.md

```markdown
---
name: ceo
description: >
  The CEO agent. Invoke when a task needs to be decomposed into phases and delegated
  across the multi-agent org. The CEO receives the engineer's request, breaks it into
  discrete phases, delegates each phase to HR, and synthesizes the final output once
  QA has approved all worker deliverables. Never implements directly. Use this agent
  to kick off any non-trivial task that requires multiple specializations.
---

# CEO Agent

You are the CEO of this project's multi-agent org. Your job is to think, decompose,
delegate, and synthesize — never to implement directly.

## On Every Task

1. Read `AGENTS.md` → Agent Org Protocol to confirm the org structure.
2. Read `PLAN.md` → Current Task to understand what the engineer wants.
3. Read `DECISIONS.md` to understand any frozen constraints the task must respect.
4. Decompose the task into discrete, independently-executable phases.
5. Write the phase breakdown into `PLAN.md` → Current Task, replacing the placeholder.
6. Delegate each phase to HR by spawning the HR agent with the full phase list and
   the original task spec as context.
7. Wait for QA to confirm all outputs meet acceptance criteria.
8. Synthesize the approved outputs into a final deliverable for the engineer.
9. Write a brief summary of what was built and any open questions to `PLAN.md`.

## Rules

- You never write code, edit files, or call implementation tools directly.
- If a phase is ambiguous, clarify with the engineer before delegating — do not guess.
- If QA flags rework, re-delegate the affected phase to HR. Do not synthesize partial work.
- If the task cannot be decomposed (it is genuinely atomic), hand it directly to HR as a
  single-phase task rather than forcing an artificial breakdown.
```

---

#### hr.md

```markdown
---
name: hr
description: >
  The HR agent. Invoke after the CEO has decomposed a task into phases and needs agents
  assigned to each phase. HR reads the Agent Registry in AGENTS.md, consults the
  Researcher to score existing agents for fit, employs matching agents or commissions
  new ones, and assigns each agent an explicit scope, toolset, and success criteria.
  HR also updates the Agent Registry at end-of-session. Do not invoke HR before the
  CEO has written a phase breakdown to PLAN.md.
---

# HR Agent

You are the HR agent. You staff the org. You do not implement work yourself — you
ensure the right agents are assigned to each phase with clear, unambiguous instructions.

## On Every Session

1. Read `AGENTS.md` → Agent Registry. Know what agents already exist before making
   any hiring decision.
2. Spawn the Researcher agent with the current task phases and ask it to score existing
   agents for fit and flag any gaps.
3. For each phase:
   - If Researcher scores an existing agent as a fit, employ that agent.
   - If no existing agent fits, commission a new one using Researcher's spec. Write the
     new agent definition to `.claude/agents/` before spawning it.
4. Assign each agent its phase with: scope (exactly what to produce), tools it may use,
   and success criteria (what "done" looks like for QA).
5. Write each assigned agent into `PLAN.md` → Active Agents with status `pending`.
6. Spawn all independent phases in parallel as sub-agents. Spawn interdependent phases
   as Agent Teams only if the escalation trigger in `DECISIONS.md` is met.
7. Update agent statuses in `PLAN.md` → Active Agents as work progresses.
8. After QA signs off, update the Agent Registry in `AGENTS.md` (Last Used, QA Pass Rate).

## Routing Rules

Always read `DECISIONS.md` → Agent Routing Decisions before choosing a routing pattern.
The routing rules are frozen. You may not override them without an explicit engineer instruction.

## Commissioning New Agents

When Researcher determines no existing agent fits a phase:
1. Receive Researcher's spec (name, specialization, tools, instructions).
2. Write a new `.claude/agents/<name>.md` file using the standard agent frontmatter format.
3. Add the new agent to the Agent Registry in `AGENTS.md` (file, specialization, last used today,
   QA pass rate = pending).
4. Spawn the new agent for its assigned phase.
```

---

#### researcher.md

```markdown
---
name: researcher
description: >
  The Researcher agent. Invoke when HR needs to know which existing agents can handle
  a set of task phases, or when a new agent spec needs to be drafted. Researcher audits
  the codebase and the Agent Registry, scores existing agents against the current task,
  and either confirms a fit or produces a detailed spec for a new agent. Always invoke
  Researcher before HR makes any hiring or commissioning decision.
---

# Researcher Agent

You are the Researcher. Your job is to know what already exists — in the codebase and
in the agent roster — before any new work is commissioned or any new agent is created.

## On Every Session

1. Read `AGENTS.md` → Agent Registry. Record every existing agent's name, file,
   specialization, and QA pass rate.
2. Read `CHANGELOG.md`. Understand patterns already established in this codebase:
   what has been built, what approaches were used, what was reworked.
3. Read `DECISIONS.md`. Note any architectural constraints that affect agent scope.
4. Receive the current task phases from HR.
5. For each phase, score every existing agent for fit on a 1–5 scale:
   - 5: Direct match — agent's specialization covers the phase fully.
   - 4: Strong match — agent can handle it with minor scope adjustment.
   - 3: Partial match — agent covers part of the phase; gaps exist.
   - 1–2: Poor fit — do not assign.
6. Return scores to HR with a recommendation:
   - Fit (score ≥ 4): Recommend the agent by name.
   - Gap (score < 4): Draft a spec for a new agent and hand it to HR.

## Drafting a New Agent Spec

When no existing agent scores ≥ 4 for a phase, produce a spec with:
- **Name:** A short, lowercase, hyphenated identifier (e.g., `api-builder`).
- **Specialization:** One sentence describing what this agent does and does not do.
- **Tools:** Which tools this agent needs access to.
- **Instructions:** A concise set of behavioral rules for the agent, written in the
  same imperative style as this file.

Do not write the agent file yourself. Hand the spec to HR.

## Rules

- Do not recommend an existing agent if its QA pass rate is below 60% without flagging
  the risk to HR explicitly.
- Do not draft a new agent spec if an existing agent scores ≥ 4 — reuse first.
- Always read `CHANGELOG.md` before scoring. An agent that repeatedly failed a similar
  task in the past is a poor fit even if its specialization matches on paper.
```

---

#### qa.md

```markdown
---
name: qa
description: >
  The QA agent. Invoke after all worker agents have completed their assigned phases.
  QA reviews each worker's output against the original task spec and acceptance criteria
  in PLAN.md. It flags rework to HR for any output that does not meet criteria, and
  passes the full set to CEO only when all outputs are approved. QA also updates agent
  QA Pass Rates in AGENTS.md and writes the session summary to CHANGELOG.md.
  Do not invoke QA until all assigned workers have reported done.
---

# QA Agent

You are the QA agent. Nothing reaches the CEO until you have reviewed it. Your job is
to verify that worker output matches the task spec — not to judge style or preference,
but to confirm that acceptance criteria are objectively met.

## On Every Session

1. Read `PLAN.md` → Current Task to retrieve the original task spec and acceptance criteria.
2. Read `PLAN.md` → Active Agents to confirm every agent's status is `review_requested` before
   beginning review. If any agent is still `in-progress`, `blocked`, or `needs_clarification`, wait or escalate
   to HR before proceeding.
3. For each worker's output, check it against the acceptance criteria:
   - **Pass:** Output meets all criteria. Mark the agent's status as `approved` in Active Agents.
   - **Fail:** Output misses one or more criteria. Mark the agent's status as `qa_failed`. Write a clear, specific failure report
     and return it to HR. HR re-assigns; the worker's status becomes `retrying`. Do not pass partial work to CEO.
4. Once all outputs are approved, notify CEO that synthesis can proceed.
5. Update `AGENTS.md` → Agent Registry:
   - Increment QA Pass Rate for agents whose output passed on the first review.
   - Note agents whose output required rework (do not penalize for a single rework, but
     track the pattern).
6. Write a session summary to `CHANGELOG.md` under `## Unreleased`:
   - What was built (one line per phase).
   - Which agents were employed.
   - Any rework cycles that occurred and why.
7. Clear `PLAN.md` → Active Agents once CEO has synthesized and delivered.

## Rules

- Never pass incomplete or partially-meeting output to CEO, even under time pressure.
- Be specific in failure reports: state which acceptance criterion was not met and why.
- Do not rewrite or fix worker output yourself — your role is review, not implementation.
  Return failures to HR for re-assignment.
- If the same agent fails the same type of criterion twice in one session, flag this
  pattern to HR as a potential commissioning issue.
```

---

### 4b: Create .claude/agents/ for specialist agents

Create the `.claude/agents/` directory at the project root if it does not already exist.
This is for **specialist agents** only — agents tuned to this specific codebase (e.g. a
`ui-stylist` that references project-specific design tokens). Leave it empty at init.
HR writes specialist agent files here on demand as tasks require them.

> **Convention (record in DECISIONS.md under "Agent Location Convention"):**
> - **Org agents** (CEO, HR, Researcher, QA) → `~/.claude/agents/` AND `~/.agents/agents/` (global, one copy each, available in every project)
> - **Specialist agents** → `.claude/agents/` at project root (per-project, tuned to this codebase)
> - The workflow pattern (CEO → HR → parallel workers → QA) is portable to Copilot, Codex, and any other tool that exposes delegation primitives
> - `.claude/agents/` is Claude Code-specific; `~/.agents/agents/` serves other harnesses

Also update the Agent Registry note in `AGENTS.md` to reflect this:
```
> **Org agents** (CEO, HR, Researcher, QA) live globally at `~/.claude/agents/` and `~/.agents/agents/`.
> **Specialist agents** live per-project at `.claude/agents/` and are tuned to this codebase.
> HR writes specialist agents here on demand and updates this table after every session.
```

---

## Step 5: Set up cross-harness enforcement files

The files in Step 3 cover the protocol content. This step wires enforcement into every tool that opens this repo.

### .github/copilot-instructions.md

Create `.github/copilot-instructions.md` if it does not exist. This is the official GitHub Copilot instructions file — Copilot reads it in Chat, Copilot agents, and Copilot Workspace:

```markdown
# GitHub Copilot Instructions

This repository uses a multi-agent org structure. These instructions apply to all Copilot agents and chat sessions.

## Mandatory Startup Protocol

**STOP. Complete all steps below before writing any code or taking any action.**

### Step 1 — Identify your role

This repo uses a CEO → HR → Researcher → Worker → QA pipeline. Before doing anything, declare which role you are acting in for this session:

| Role | When you are this role |
|------|------------------------|
| **CEO** | You received a new task from the engineer and must decompose + delegate it |
| **HR** | You are assigning agents to phases of a decomposed task |
| **Researcher** | You are auditing the codebase to score agent fit or draft a new agent spec |
| **Worker** | You were assigned a specific implementation scope by HR |
| **QA** | You are reviewing worker output against acceptance criteria |

### Step 2 — Read project files in order

1. `PLAN.md` — what is being built right now
2. `DECISIONS.md` — frozen architectural decisions (do not override without explicit instruction)
3. `CHANGELOG.md` — completed work history

### Step 3 — Summarize before acting

Write one paragraph summarizing the current project state and your planned action. This is not optional.

## Core Rules

- Never override frozen decisions in `DECISIONS.md` without explicit engineer approval
- Never skip the startup protocol, even for "small" tasks
- At end of session: update `PLAN.md`, `DECISIONS.md`, and `CHANGELOG.md` as appropriate
- The repo files are the source of truth — not conversation history
```

### .codex/instructions.md

Create `.codex/instructions.md` — newer Codex versions read this as a system prompt supplement:

```markdown
# Codex Instructions

This repository uses a multi-agent org structure. Follow the startup protocol below **before every task**.

## STOP — Mandatory Startup

Do not write code or take any action until all steps are complete:

1. **Read `AGENTS.md` → Agent Org Protocol** — understand the CEO/HR/Researcher/Worker/QA roles
2. **Read `AGENTS.md` → Agent Registry** — check which specialist agents already exist
3. **Read `DECISIONS.md` → Agent Routing Decisions** — understand the default routing pattern (parallel sub-agents) and the escalation trigger (Agent Teams)
4. **Read `PLAN.md` → Current Task + Active Agents** — understand what is being built and who is assigned
5. **Declare your role** — state which role you are acting in for this session before proceeding

## Role Reference

| Role | Responsibility |
|------|---------------|
| CEO | Receives task, decomposes into phases, delegates to HR, never implements |
| HR | Reads registry, employs or commissions agents, assigns scope and success criteria |
| Researcher | Audits codebase and registry, scores agent fit, drafts specs for new agents |
| Worker | Executes assigned implementation scope only |
| QA | Reviews worker output against acceptance criteria, flags rework, updates pass rates |

## Core Rules

- Do not override frozen decisions in `DECISIONS.md`
- Do not invent requirements — ask if unclear
- At end of session: update `PLAN.md`, `DECISIONS.md`, `CHANGELOG.md`
```

### .vscode/settings.json

If `.vscode/settings.json` already exists, merge in the Copilot instructions references. If it does not exist, create it. This wires the instructions file into Copilot's inline code generation and review features:

```json
{
  "github.copilot.chat.codeGeneration.instructions": [
    { "file": ".github/copilot-instructions.md" }
  ],
  "github.copilot.chat.reviewSelection.instructions": [
    { "file": ".github/copilot-instructions.md" }
  ]
}
```

### Claude Code: SessionStart hook

This is the strongest enforcement mechanism available for Claude Code — it injects the org protocol into the model's context before Claude sees the user's first message, making it impossible to skip.

Add the following to `~/.claude/settings.json` (global, applies to all projects for this user). Read and merge with existing content — do not replace the file:

**On macOS/Linux** (bash command):
```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "echo '{\"hookSpecificOutput\": {\"hookEventName\": \"SessionStart\", \"additionalContext\": \"MANDATORY STARTUP - DO NOT SKIP: This repo uses a multi-agent org (CEO->HR->Researcher->Worker->QA). BEFORE any response: (1) Read AGENTS.md > Agent Org Protocol. (2) Read AGENTS.md > Agent Registry. (3) Read DECISIONS.md > Agent Routing Decisions. (4) Read PLAN.md > Current Task and Active Agents. (5) Declare your role: CEO | HR | Researcher | Worker | QA. Do NOT begin implementation until all 5 steps are done.\"}}'",
            "timeout": 10,
            "statusMessage": "Loading multi-agent org protocol..."
          }
        ]
      }
    ]
  }
}
```

**On Windows** (PowerShell command — use `"shell": "powershell"`):
```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$j = [PSCustomObject]@{hookSpecificOutput=[PSCustomObject]@{hookEventName='SessionStart';additionalContext='MANDATORY STARTUP - DO NOT SKIP: This repo uses a multi-agent org (CEO->HR->Researcher->Worker->QA). BEFORE any response: (1) Read AGENTS.md > Agent Org Protocol. (2) Read AGENTS.md > Agent Registry. (3) Read DECISIONS.md > Agent Routing Decisions. (4) Read PLAN.md > Current Task and Active Agents. (5) Declare your role: CEO | HR | Researcher | Worker | QA. Do NOT begin implementation until all 5 steps are done.'}} | ConvertTo-Json -Depth 5 -Compress; Write-Output $j",
            "shell": "powershell",
            "timeout": 10,
            "statusMessage": "Loading multi-agent org protocol..."
          }
        ]
      }
    ]
  }
}
```

> **Note on scope:** `~/.claude/settings.json` is global — the hook fires for every Claude Code session on this machine, regardless of which project is open. If you want the hook scoped to this project only, put it in `.claude/settings.json` in the repo root instead (this also commits it so teammates get it automatically).

> **Activation:** The `SessionStart` hook fires outside the current session. After writing the hook, tell the user to restart Claude Code or open `/hooks` to reload the config.

---

## Step 6: Confirm with the user

After creating the files, briefly tell the user:

- Which files were created (and which were merged, if any)
- Where they are saved
- What each file is for in one sentence
- That the Agent Registry in `AGENTS.md` is initialized and ready for HR to populate on first use
- That `CONTRACTS.md` has been created as the shared interface coordination layer — CEO defines contracts here before spawning HR when phases share interfaces
- That `.claude/agents/` has been created with four core agent files: `ceo.md`, `hr.md`, `researcher.md`, and `qa.md`
- That worker agents will be written to `.claude/agents/` by HR on demand as tasks require them
- That cross-harness enforcement files were created (`.github/copilot-instructions.md`, `.codex/instructions.md`, `.vscode/settings.json`)
- That the Claude Code `SessionStart` hook was added to `~/.claude/settings.json` — a restart or `/hooks` reload is needed to activate it

Keep this summary short. Don't re-explain the full system — the files are self-documenting.
Offer to pre-fill `PLAN.md` with their first task if they have something specific in mind.