# Thread Memory

[English](README.md) | [简体中文](README.zh-CN.md)

面向编码 Agent 的持久化线程记忆。

Thread Memory 会为 Codex、Claude Code、Gemini CLI、OpenCode 以及类似 Agent 运行环境中的每个对话或工作区创建一个小型、持久化的 `README.md`。Agent 在开始实质性工作前读取它，在结束前更新它，这样长任务就能在上下文压缩、进程重启或隔一段时间继续工作时保持连续性。

## 快速开始

用一条命令安装到某个宿主：

```bash
curl -fsSL https://raw.githubusercontent.com/kooroEZP/thread-memory/main/install.sh | bash -s -- --codex
```

```bash
curl -fsSL https://raw.githubusercontent.com/kooroEZP/thread-memory/main/install.sh | bash -s -- --claude
```

安装到所有支持的本地宿主：

```bash
curl -fsSL https://raw.githubusercontent.com/kooroEZP/thread-memory/main/install.sh | bash -s -- --all
```

从本地 checkout 安装：

```bash
./install.sh --source . --codex
```

## 会安装什么

- `skills/thread-memory/` 会被复制到所选宿主的 skills 目录。
- `thread-memory` CLI 会安装到 `~/.local/bin/thread-memory`。
- 如果宿主有全局指令文件，安装器会加入一个受管理的指令区块：
  - Codex：`${CODEX_HOME:-~/.codex}/AGENTS.md`
  - Claude Code：`${CLAUDE_HOME:-~/.claude}/CLAUDE.md`
- Gemini CLI 会在 `${GEMINI_HOME:-~/.gemini}/extensions/thread-memory` 下获得一个 extension 目录。
- OpenCode 会在 `${OPENCODE_CONFIG_DIR:-~/.config/opencode}/plugins/thread-memory` 下获得一个本地插件目录。

安装器是幂等的。重复执行会刷新 skill，并且只替换它自己管理的指令区块。

## 原生插件元数据

这个仓库也包含不同宿主的原生插件或扩展元数据：

- Codex：`.codex-plugin/plugin.json`
- Claude Code：`.claude-plugin/plugin.json` 和 `.claude-plugin/marketplace.json`
- Gemini CLI：`gemini-extension.json` 和 `GEMINI.md`
- OpenCode：`package.json` 和 `.opencode/plugins/thread-memory.js`

发布到 GitHub 后，这些文件可以支持类似 `obra/superpowers` 的 marketplace 或 git-backed 安装流程。

## CLI

CLI 用来定位或初始化记忆文件：

```bash
thread-memory ensure --cwd "$PWD"
```

常用选项：

```bash
thread-memory path --cwd "$PWD"
thread-memory ensure --cwd "$PWD" --thread-id "$CODEX_THREAD_ID"
thread-memory ensure --cwd "$PWD" --root "$HOME/.thread-memory/threads"
```

环境变量：

- `THREAD_MEMORY_ROOT`：覆盖记忆根目录。
- `THREAD_MEMORY_ID`：显式指定对话或会话 id。
- `CODEX_THREAD_ID`、`CLAUDE_SESSION_ID`、`CLAUDE_CONVERSATION_ID`、`GEMINI_SESSION_ID`、`OPENCODE_SESSION_ID`：在存在时用于尽力识别宿主会话。

如果没有可用的 session id，CLI 会基于 `--cwd` 的绝对路径生成稳定的 workspace key。

## 仓库结构

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

## 发布清单

1. 确认仓库元数据指向 `https://github.com/kooroEZP/thread-memory`。
2. 使用 semver 打 tag，例如 `v0.1.0`。
3. 用 `THREAD_MEMORY_REF=v0.1.0` 测试安装命令。
4. 如果需要官方 marketplace 发现能力，再提交 Codex 和 Claude 的插件元数据。

## 开发

运行测试：

```bash
python3 -m unittest discover -s tests
```

用临时 HOME 做本地安装冒烟测试，避免改动真实配置：

```bash
HOME="$(mktemp -d)" ./install.sh --source . --all
```

## 许可证

MIT
