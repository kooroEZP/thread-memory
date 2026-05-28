# Thread Memory

[English](README.md) | [简体中文](README.zh-CN.md)

Project-state memory for AI coding agents, LLM developer tools, and long-running software work.

Thread Memory gives Codex, Claude Code, Gemini CLI, OpenCode, and similar agent harnesses a small durable `README.md` for each conversation or workspace. Agents read it before substantive work and update it before finishing a turn, so the important project state survives context compaction, restarts, tool switches, and human handoffs.

Keywords: AI agent memory, LLM memory, project memory, durable agent state, persistent conversation memory, context persistence, context management, agent handoff, Codex skill, Claude Code skill, Gemini CLI, OpenCode, OpenAI-compatible API proxy, API relay, account pool, key pool.

## Why Thread Memory

AI coding tools already manage conversation context. Thread Memory does not replace that. It adds a small, explicit project-state layer that is easy for agents and humans to inspect.

This matters because automatic context management is not a durable project notebook. Context can become incomplete or too vague when:

- a conversation is compacted or summarized by the host tool
- a session is restarted, resumed on another machine, or continued in another tool
- the task spans multiple repositories, branches, worktrees, terminals, or days
- important details live in tool output that later gets trimmed from context
- an OpenAI-compatible API relay, gateway, reverse proxy, account pool, or key pool makes upstream session/cache continuity less predictable
- the agent relies on chat history instead of a durable project-local summary

Thread Memory is not a transcript archive. It stores the small set of facts an agent needs to resume work safely: the current objective, durable context, decisions, important files, verification commands, known risks, recent progress, next steps, and open questions.

## What It Is Not

- Not a replacement for Codex, Claude Code, Gemini CLI, or OpenCode context management.
- Not a vector database, RAG system, or long-term personal memory store.
- Not a place to save secrets, raw logs, full diffs, or entire chat transcripts.
- Not proof that API relays or account pools lose context. They usually work if the client sends the needed context. Thread Memory just lowers the risk when continuity depends on summaries, local state, or host-specific behavior.

## Good Fit For

- Codex, Claude Code, Gemini CLI, OpenCode, and other AI coding agents
- project memory for agentic coding workflows
- long-running feature work, debugging, refactors, migrations, and repository maintenance
- handoffs between agents, tools, terminals, machines, or humans
- preserving decisions, test commands, known risks, and file pointers after context compaction
- OpenAI-compatible API proxy or relay setups where server-side session continuity should not be assumed
- teams that want a simple local memory layer without a database or external service

## What Agents Record

The default memory file keeps a short, structured handoff:

- current objective
- durable project context
- decisions and constraints
- important files and modules
- commands and verification status
- known risks and gotchas
- recent progress
- next steps
- open questions

## Quickstart

Install for one host with one command:

```bash
curl -fsSL https://raw.githubusercontent.com/kooroEZP/thread-memory/main/install.sh | bash -s -- --codex
```

```bash
curl -fsSL https://raw.githubusercontent.com/kooroEZP/thread-memory/main/install.sh | bash -s -- --claude
```

Install for all supported local hosts:

```bash
curl -fsSL https://raw.githubusercontent.com/kooroEZP/thread-memory/main/install.sh | bash -s -- --all
```

Install from a local checkout:

```bash
./install.sh --source . --codex
```

## What Gets Installed

- `skills/thread-memory/` is copied into the selected host's skills directory.
- `thread-memory` CLI is installed to `~/.local/bin/thread-memory`.
- A managed instruction block is added to the host's global instruction file when the host has one:
  - Codex: `${CODEX_HOME:-~/.codex}/AGENTS.md`
  - Claude Code: `${CLAUDE_HOME:-~/.claude}/CLAUDE.md`
- Gemini CLI receives an extension folder under `${GEMINI_HOME:-~/.gemini}/extensions/thread-memory`.
- OpenCode receives a local plugin folder under `${OPENCODE_CONFIG_DIR:-~/.config/opencode}/plugins/thread-memory`.

The installer is idempotent. Re-running it refreshes the skill and replaces only the managed instruction block.

## Native Plugin Metadata

This repository also includes metadata for native plugin or extension flows:

- Codex: `.codex-plugin/plugin.json`
- Claude Code: `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`
- Gemini CLI: `gemini-extension.json` and `GEMINI.md`
- OpenCode: `package.json` and `.opencode/plugins/thread-memory.js`

After publishing to GitHub, these files make the project ready for marketplace or git-backed installation flows similar to `obra/superpowers`.

## CLI

The CLI locates or initializes the memory file:

```bash
thread-memory ensure --cwd "$PWD"
```

Useful options:

```bash
thread-memory path --cwd "$PWD"
thread-memory ensure --cwd "$PWD" --thread-id "$CODEX_THREAD_ID"
thread-memory ensure --cwd "$PWD" --root "$HOME/.thread-memory/threads"
```

Environment variables:

- `THREAD_MEMORY_ROOT`: override the memory root directory.
- `THREAD_MEMORY_ID`: explicit conversation/session id.
- `CODEX_THREAD_ID`, `CLAUDE_SESSION_ID`, `CLAUDE_CONVERSATION_ID`, `GEMINI_SESSION_ID`, `OPENCODE_SESSION_ID`: best-effort host ids used when present.

When no session id is available, the CLI falls back to a stable workspace key based on the absolute `--cwd`.

## FAQ

### Does this duplicate built-in context management?

No. Built-in context management decides what to send to the model for the next request. Thread Memory keeps a durable, human-readable project state summary on disk. The two layers complement each other.

### Do API relays or account pools make context disappear?

Not by themselves. If the host tool sends the needed messages, summaries, tool results, and files each time, upstream account changes do not automatically erase context. The risk is that session/cache assumptions, model routing, long gaps, or lossy summaries can make continuity less reliable. Thread Memory makes the critical state explicit and local.

## Repository Layout

```text
thread-memory/
├── .codex-plugin/plugin.json
├── .claude-plugin/
├── .opencode/plugins/thread-memory.js
├── bin/thread-memory
├── gemini-extension.json
├── install.sh
├── package.json
├── scripts/thread_memory.py
├── skills/thread-memory/
└── tests/
```

## Publishing Checklist

1. Verify repository metadata points to `https://github.com/kooroEZP/thread-memory`.
2. Tag releases with semver, for example `v0.1.0`.
3. Test installer commands with `THREAD_MEMORY_REF=v0.1.0`.
4. Submit the Codex and Claude plugin metadata to their marketplace workflows when you want official marketplace discovery.

## Development

Run tests:

```bash
python3 -m unittest discover -s tests
```

Run local install smoke tests without touching your real home:

```bash
HOME="$(mktemp -d)" ./install.sh --source . --all
```

## License

MIT
