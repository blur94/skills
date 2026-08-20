---
name: pr-description
description: Writes pull request titles and bodies in a fixed house format - imperative title under 72 characters, a what/where/why summary paragraph, level-3 themed sections with action-verb bullets, and a closing impact statement. Use when creating, raising, or opening a pull request in any repository, when rewriting or editing an existing PR description, and as the description step of a ship or release workflow.
---

# PR descriptions

Applies to every repository. If a repo ships its own `pr-description` skill or
documents a different PR format in its `CLAUDE.md`, that one wins.

## Quick start

Gather the facts, write the body to a file, then create the PR. Always use
`--body-file` - heredocs and inline `--body` mangle backticks and quotes.

```bash
git log --oneline <base>..HEAD
git diff --stat <base>...HEAD
gh pr create --base <base> --title "<title>" --body-file <path>
```

Verify the metadata landed:

```bash
gh pr view <number> --json title,assignees,reviewRequests,baseRefName
```

## Per-repository details

Do not assume these - read them from the repo before opening the PR:

- **Base branch.** Check `git remote show origin`, the repo's `CLAUDE.md`, or
  what recent merged PRs targeted. Many repos merge to `develop` or `dev`
  rather than `main`.
- **Assignee and reviewer defaults**, if the repo or the user has standing ones.
- **An existing `.github/pull_request_template.md`**, whose sections take
  precedence over the generic ones below.

## Writing the description

Work through this checklist in order:

- [ ] **Title** - imperative, max 72 characters. Count them.
      Good: `Refactor HeaderComponent for accessibility`
- [ ] **Summary paragraph** - opens the body, no header above it. States what
      changed, where it changed (name the files or areas), and why.
- [ ] **Themed sections** - group changes under `###` headers named for the
      actual themes in the diff, not from a fixed list. `### Payment Reminders`
      and `### Types` beat generic `### Changes`.
- [ ] **Bullets** - every bullet opens with an action verb (Added, Updated,
      Removed, Refactored, Restricted, Replaced) and names concrete files or
      components in `inline code`.
- [ ] **UI section** - if any UI changed, state the components touched and the
      responsiveness or accessibility impact explicitly. Say whether the change
      was visually verified.
- [ ] **Optional sections** - add `### Testing`, `### Performance Impact`, or
      `### Breaking Changes` only when there is something real to report.
      Under Breaking Changes, write `None.` rather than omitting it when the
      diff touches shared types or public interfaces.
- [ ] **Impact statement** - close with one or two sentences on the overall
      benefit, in terms of what a user or developer can now do.

## Tone

Professional, clear, direct. No filler, no meta commentary about the PR or the
process of writing it. Optimize for a reviewer skimming the body once.

Do not pad thin changes into many sections - a one-theme PR gets one section.

## Reporting honestly

The description is a claim to a reviewer, so it has to hold up:

- State test results as run, including failures and skips.
- If a change could not be verified (no credentials, no environment), say so in
  the relevant section rather than implying it was checked.
- Never describe work that is not in the diff.
