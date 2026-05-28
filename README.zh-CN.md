# Thread Memory

[English](README.md) | [简体中文](README.zh-CN.md)

面向 AI 编码 Agent、LLM 开发工具和长任务编码会话的本地持久化记忆。

Thread Memory 会为 Codex、Claude Code、Gemini CLI、OpenCode 以及类似 Agent 运行环境中的每个对话或工作区创建一个小型、持久化的 `README.md`。Agent 在开始实质性工作前读取它，在结束前更新它，这样长任务就能在上下文压缩、进程重启、中转 API/代理路由、或隔一段时间继续工作时保持连续性。

关键词：AI Agent 记忆、LLM 记忆、持久化会话记忆、上下文持久化、上下文管理、Codex skill、Claude Code skill、OpenAI 兼容 API 代理、中转 API、API relay、号池、key pool。

## 为什么需要 Thread Memory

AI 编码 Agent 经常需要跨很多轮对话、很多天、甚至很多次模型调用保持连续性。下面这些情况都可能让上下文变得不完整：

- 宿主工具对会话做了上下文压缩或摘要
- 长时间间隔后重新打开同一个编码任务
- 一个任务跨多个仓库、分支或终端
- OpenAI 兼容 API 中转、网关、反向代理、号池或 key 池把请求路由到不同的上游账号或模型
- Agent 只依赖聊天记录，而没有一个可持久保存的项目状态摘要

Thread Memory 不替代完整聊天记录。它只保存 Agent 安全恢复工作所需的少量关键事实：当前目标、稳定上下文、已做决策、重要文件、最近进展、下一步和开放问题。

## 适合的场景

- Codex、Claude Code、Gemini CLI、OpenCode 以及其他 AI 编码 Agent
- Agentic coding workflow 的持久化记忆
- 长周期功能开发、调试、重构和仓库维护
- 使用 OpenAI 兼容 API 代理、中转 API 或号池时，不能假设服务端 session 一定连续的场景
- 想要一个不依赖数据库或外部服务的简单本地记忆层

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
