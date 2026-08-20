---
name: fetch-clickup-tasks
description: Fetches the current user's TO-DO tasks from ClickUp and displays them as a formatted table. Use this skill whenever the user says "fetch my tasks", "show my tasks", "get my to-dos", "what are my ClickUp tasks", "what do I need to work on", or anything about checking their task list. Also invoke this when the user asks to see tasks from a specific list or project. Always use this skill — don't attempt to call ClickUp tools directly without it.
---

# Fetch ClickUp Tasks

Fetch all ClickUp tasks assigned to the user with TO-DO status, expand any subtasks, and display them as a formatted table.

**Model split:** You (the orchestrating Claude instance) handle memory reads/writes and any user interaction. A **Haiku sub-agent** handles all ClickUp API calls and table generation — this keeps the mechanical fetching fast and cheap.

---

## Step 1: Check memory for stored context

Memory is split across two scopes:

- **User ID** lives in **global memory** (`~/.claude/memory/clickup_user.md`). It never changes — once saved, it's available in every project.
- **List context** lives in **project memory** (`memory/clickup_context.md` in the current project). It is project-specific — different projects will have different preferred lists.

Check both files. You need:
- **User ID** — from global memory
- **List context** — from project memory: list name, ID, folder, and space

If both are present, skip Step 2. Tell the user briefly: "Fetching from [List Name]..." and go straight to Step 3.

If the user says "fetch from [different list]" or "use a different project", override just the list part and re-run Step 2b. The user ID never needs to be re-discovered.

---

## Step 2: Discover workspace (only when context is missing)

### 2a: Get the user's ID

Only run this if global memory (`~/.claude/memory/clickup_user.md`) has no user ID yet.

Call `clickup_get_workspace_members`. Find the member that matches the person you're talking to. If ambiguous, ask. Note the user ID — you'll pass it to the sub-agent and save it to **global memory** (`~/.claude/memory/clickup_user.md`).

### 2b: Show hierarchy and ask which list to use

Call `clickup_get_workspace_hierarchy`. Present the structure compactly and ask:

> Here's your workspace — which list should I fetch tasks from?
>
> **Space: Product**
> - Folder: Sprint 5 → Backlog, In Progress
> - Folder: Design → UI Tasks

If the user's phrasing already implies a list (e.g. "fetch from the backlog"), try to match it — but confirm if you're not certain. Once the user picks, note the list ID, name, folder, and space.

---

## Step 3: Spawn a Haiku sub-agent to fetch and format tasks

Now that you have the user ID and list ID, hand off to a **Haiku** sub-agent. Use the Agent tool with `model: "haiku"`.

Pass this prompt to the sub-agent (fill in the bracketed values):

```
You are fetching TO-DO tasks from ClickUp for a specific user.

Context:
- List ID: [list_id]
- List Name: [list_name]
- User ID: [user_id]
- Status to fetch: "TO-DO" (fallback: "to-do" if no results)

Instructions:

1. Call `clickup_filter_tasks` with list_id=[list_id], statuses=["TO-DO"], assignees=[[user_id]].
   If no results, retry with statuses=["to-do"].
   If still no results, return: "No TO-DO tasks found for you in [list_name]."

2. For each task returned, first check: does it have subtasks (subtask_count > 0)?

   **YES — has subtasks:**
   Call `clickup_get_task` to get full subtask details. Filter the subtasks to only those where:
     a. status is "TO-DO" (or "to-do")
     b. assignees includes [user_id]
   Add each qualifying subtask to the display list with the parent task's name recorded.
   The parent task MUST NOT appear as a row — not ever, regardless of its own status or assignee.
   If zero subtasks qualify, skip this parent entirely (add nothing).

   **NO — no subtasks:**
   Add the task directly to the display list with "—" as Parent Task.

3. Render the flat list as a Markdown table:

| Task Name | Parent Task | Due Date | Priority | Description |
|-----------|-------------|----------|----------|-------------|

Column rules:
- Task Name: wrap in [name](url) if the task URL is available
- Parent Task: parent task name for subtasks; "—" for standalone tasks
- Due Date: format as "MMM DD" (e.g. "Jan 15"); "—" if not set
- Priority: Urgent / High / Normal / Low; "—" if unset
- Description: first 120 chars of task description, truncated with "..." if longer; "—" if empty

4. After the table add this summary line:
   Showing **N tasks** from **[list_name]** · [X standalone, Y subtasks]

Return only the table and summary line — no other commentary.
```

---

## Step 4: Display and save

Display the table and summary line returned by the sub-agent exactly as-is.

Save to two separate files:

**1. Global memory** — `~/.claude/memory/clickup_user.md` (only if user ID wasn't already there):
```markdown
---
name: ClickUp user identity
description: ClickUp user ID and profile — used by fetch-clickup-tasks skill across all projects
type: reference
---

## User
- **User ID**: <id>
- **Name**: <name>
- **Email**: <email>
```

**2. Project memory** — `memory/clickup_context.md` in the current project (add new lists, don't overwrite existing rows):
```markdown
---
name: ClickUp list context
description: ClickUp lists used in this project — pairs with global clickup_user.md for the fetch-clickup-tasks skill
type: reference
---

## Lists used
| List Name | List ID | Folder | Space |
|-----------|---------|--------|-------|
| Backlog   | abc123  | Sprint 5 | Product |
```

Add new lists as they are used. This builds up over time so the skill knows which lists belong to which project.
