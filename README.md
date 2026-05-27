# Thread Memory

[English](README.md) | [简体中文](README.zh-CN.md)

Persistent per-thread memory for coding agents.

Thread Memory gives Codex, Claude Code, Gemini CLI, OpenCode, and similar agent harnesses a small durable `README.md` for each conversation or workspace. Agents read it before substantive work and update it before finishing a turn, so long-running sessions can survive context compaction, restarts, and gaps between work sessions.

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
