---
name: thread-memory
description: Persistent project-state memory for AI coding-agent conversations and workspaces. Use at the start of every substantive Codex, Claude Code, Gemini CLI, OpenCode, or other agent turn to read a durable memory README, and use again before finishing to update objective, decisions, constraints, important files, verification commands, known risks, progress, open questions, and next steps.
---

# Thread Memory

Maintain one durable `README.md` for the current agent thread or workspace. Treat it as a small project-state handoff, not a transcript archive. Read it before substantive work and update it before finishing so future sessions can resume accurately after context compaction, process restarts, tool switches, or human handoffs.

## Operating Model

- Complement the host tool's context management; do not assume this replaces the chat transcript.
- Preserve only durable facts that affect future work.
- Prefer verified repository state over memory whenever they conflict.
- Keep the memory useful for a fresh agent that knows nothing except the repo and this file.

## Workflow

### 1. Locate the current memory file

Prefer the installed CLI:

```bash
thread-memory ensure --cwd "$PWD"
```

If `thread-memory` is not on `PATH`, run the bundled script from this skill directory:

```bash
python3 scripts/thread_memory.py ensure --cwd "$PWD"
```

The command prints the absolute path of the memory `README.md`.

Thread id detection is best effort. The CLI checks `THREAD_MEMORY_ID`, `CODEX_THREAD_ID`, `CLAUDE_SESSION_ID`, `CLAUDE_CONVERSATION_ID`, `GEMINI_SESSION_ID`, and `OPENCODE_SESSION_ID`. If none are set, it falls back to a stable workspace key.

### 2. Read memory before substantive work

- Read the returned `README.md` before analysis, coding, or detailed answers.
- Treat it as durable hints, not ground truth.
- If the memory conflicts with the repository or the user's latest request, trust the repository and update memory later.

### 3. Update memory before finishing

Before every substantive final response, refresh the same `README.md` with concise durable context:

- current objective
- stable project or product context
- decisions and constraints
- important files, modules, or commands
- commands run and verification status
- known risks, gotchas, or failed approaches
- recent progress that matters later
- next steps
- open questions or blockers

Do not append an unbounded chat log. Replace stale content and keep the file concise.

Update memory after significant decisions, completed implementation steps, failed debugging paths, test results, branch/worktree changes, or user corrections. For tiny one-off answers, keep the update minimal.

### 4. Confirm the update

In the final response, include one short sentence confirming the memory file path.

Chinese template:

```text
当前对话框上下文信息已更新至 <absolute-path>。
```

English template:

```text
Thread context has been updated in <absolute-path>.
```

## Memory Format

Preserve these headings:

- `## Current Objective`
- `## Durable Context`
- `## Decisions and Constraints`
- `## Important Files`
- `## Commands and Verification`
- `## Known Risks and Gotchas`
- `## Recent Progress`
- `## Next Steps`
- `## Open Questions`

Use short bullets or short paragraphs. Optimize for fast reloading by a future agent.

## Practical Rules

- Rewrite `## Current Objective` and `## Next Steps` whenever the thread changes direction.
- Prefer stable facts over speculation.
- Mark unverified assumptions explicitly.
- Keep `## Important Files` limited to the files, directories, or commands that matter for resuming the thread.
- Keep `## Commands and Verification` focused on commands that were actually run and their outcome.
- Keep `## Known Risks and Gotchas` focused on pitfalls a future agent might otherwise rediscover.
- If the task spans more than one repository or workspace, note the boundaries in `## Durable Context`.
- Do not store secrets, tokens, passwords, or other sensitive values.
- Do not store full logs, full diffs, raw stack traces, or long chat excerpts unless a short excerpt is essential.
