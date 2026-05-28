# Thread Memory

[English](README.md) | [简体中文](README.zh-CN.md)

Persistent local memory for AI coding agents, LLM developer tools, and long-running coding sessions.

Thread Memory gives Codex, Claude Code, Gemini CLI, OpenCode, and similar agent harnesses a small durable `README.md` for each conversation or workspace. Agents read it before substantive work and update it before finishing a turn, so long-running sessions can survive context compaction, restarts, API relay/proxy routing, and long gaps between work sessions.

Keywords: AI agent memory, LLM memory, persistent conversation memory, context persistence, context management, Codex skill, Claude Code skill, OpenAI-compatible API proxy, API relay, account pool, key pool.

## Why Thread Memory

AI coding agents often need continuity across many turns, multiple days, or multiple model calls. Context can become incomplete when:

- a conversation is compacted or summarized by the host tool
- a coding session is restarted after a long break
- the task spans multiple repositories, branches, or terminals
- an OpenAI-compatible API relay, gateway, reverse proxy, account pool, or key pool routes calls through different upstream accounts or models
- the agent relies on chat history instead of a durable project-local summary

Thread Memory does not replace the full chat transcript. It stores the small set of facts an agent needs to resume work safely: the current objective, durable context, decisions, important files, recent progress, next steps, and open questions.

## Good Fit For

- Codex, Claude Code, Gemini CLI, OpenCode, and other AI coding agents
- persistent memory for agentic coding workflows
- long-running feature work, debugging, refactors, and repository maintenance
- OpenAI-compatible API proxy or relay setups where session continuity cannot be assumed
- teams that want a simple local memory layer without a database or external service

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
