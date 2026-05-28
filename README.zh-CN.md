# Thread Memory

[English](README.md) | [简体中文](README.zh-CN.md)

面向 AI 编码 Agent、LLM 开发工具和长期软件工作的项目状态记忆。

Thread Memory 会为 Codex、Claude Code、Gemini CLI、OpenCode 以及类似 Agent 运行环境中的每个对话或工作区创建一个小型、持久化的 `README.md`。Agent 在开始实质性工作前读取它，在结束前更新它，让重要的项目状态能跨上下文压缩、进程重启、工具切换和人工交接继续保留。

关键词：AI Agent 记忆、LLM 记忆、项目记忆、Agent durable state、持久化会话记忆、上下文持久化、上下文管理、Agent 交接、Codex skill、Claude Code skill、Gemini CLI、OpenCode、OpenAI 兼容 API 代理、中转 API、API relay、号池、key pool。

## 为什么需要 Thread Memory

AI 编码工具本身通常会管理对话上下文。Thread Memory 不替代它们的上下文管理，而是额外提供一个明确、可检查的项目状态层。

这个层有价值，是因为自动上下文管理并不等于一个持久、准确的项目笔记。下面这些情况都可能让上下文变得不完整或过于粗略：

- 宿主工具对会话做了上下文压缩或摘要
- 会话重启、换机器继续、或换到另一个工具继续
- 一个任务跨多个仓库、分支、worktree、终端或多天
- 关键细节只存在于工具输出里，后续被上下文裁剪掉
- OpenAI 兼容 API 中转、网关、反向代理、号池或 key 池让上游 session/cache 连续性更不可控
- Agent 只依赖聊天记录，而没有一个可持久保存的项目状态摘要

Thread Memory 不是聊天记录归档。它只保存 Agent 安全恢复工作所需的少量关键事实：当前目标、稳定上下文、已做决策、重要文件、验证命令、已知风险、最近进展、下一步和开放问题。

## 它不是什么

- 不是 Codex、Claude Code、Gemini CLI 或 OpenCode 上下文管理的替代品。
- 不是向量数据库、RAG 系统或长期个人记忆库。
- 不是保存密钥、原始日志、完整 diff 或整段聊天记录的地方。
- 也不是在宣称中转 API 或号池一定会丢上下文。只要客户端发送了所需上下文，它们通常可以正常工作。Thread Memory 只是当连续性依赖摘要、本地状态或宿主特定行为时，降低关键状态丢失的风险。

## 适合的场景

- Codex、Claude Code、Gemini CLI、OpenCode 以及其他 AI 编码 Agent
- Agentic coding workflow 的项目记忆
- 长周期功能开发、调试、重构、迁移和仓库维护
- 在 Agent、工具、终端、机器或人之间做交接
- 在上下文压缩后保留决策、测试命令、已知风险和文件指针
- 使用 OpenAI 兼容 API 代理、中转 API 或号池时，不希望依赖服务端 session 一定连续的场景
- 想要一个不依赖数据库或外部服务的简单本地记忆层

## Agent 会记录什么

默认记忆文件是一份短小、结构化的交接说明：

- 当前目标
- 稳定项目上下文
- 决策和约束
- 重要文件和模块
- 命令和验证状态
- 已知风险和坑点
- 最近进展
- 下一步
- 开放问题

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

## FAQ

### 这会不会和内置上下文管理重复？

不会。内置上下文管理决定下一次请求要给模型发送什么。Thread Memory 则在磁盘上保存一份持久、可读的项目状态摘要。这两层是互补关系。

### 中转 API 或号池会让上下文消失吗？

不会天然消失。只要宿主工具每次都发送所需的消息、摘要、工具结果和文件，上游账号切换并不会自动抹掉上下文。真正的风险是 session/cache 假设、模型路由、长时间间隔或有损摘要让连续性变得不可靠。Thread Memory 把关键状态明确落到本地。

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
