#!/usr/bin/env python3
"""Locate or initialize a durable README for the current agent thread."""

from __future__ import annotations

import argparse
import hashlib
import os
import re
from datetime import datetime
from pathlib import Path


DEFAULT_THREAD_ENV_VARS = (
    "THREAD_MEMORY_ID",
    "CODEX_THREAD_ID",
    "CLAUDE_SESSION_ID",
    "CLAUDE_CONVERSATION_ID",
    "GEMINI_SESSION_ID",
    "OPENCODE_SESSION_ID",
)


def now_local() -> str:
    return datetime.now().astimezone().isoformat(timespec="seconds")


def sanitize_name(value: str) -> str:
    cleaned = re.sub(r"[^A-Za-z0-9._-]+", "-", value.strip())
    cleaned = cleaned.strip("-")
    return cleaned or "workspace"


def default_memory_root() -> Path:
    configured = os.environ.get("THREAD_MEMORY_ROOT", "").strip()
    if configured:
        return Path(configured).expanduser()
    return Path.home() / ".thread-memory" / "threads"


def detect_thread_id() -> str | None:
    for name in DEFAULT_THREAD_ENV_VARS:
        value = os.environ.get(name, "").strip()
        if value:
            return value
    return None


def build_key(cwd: str, thread_id: str | None) -> str:
    if thread_id:
        return f"thread-{sanitize_name(thread_id)}"
    workspace = sanitize_name(Path(cwd).name)
    digest = hashlib.sha1(cwd.encode("utf-8")).hexdigest()[:12]
    return f"workspace-{workspace}-{digest}"


def readme_path(cwd: str, thread_id: str | None, root: Path) -> Path:
    key = build_key(cwd, thread_id)
    return root / key / "README.md"


def render_template(cwd: str, thread_id: str | None) -> str:
    timestamp = now_local()
    thread_label = thread_id or "workspace-fallback"
    return f"""# Thread Memory

- Thread ID: `{thread_label}`
- Workspace: `{cwd}`
- Created: `{timestamp}`
- Last Updated: `{timestamp}`

## Current Objective

-

## Durable Context

-

## Decisions and Constraints

-

## Important Files

-

## Recent Progress

-

## Next Steps

-

## Open Questions

-
"""


def ensure_readme(path: Path, cwd: str, thread_id: str | None) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    if not path.exists():
        path.write_text(render_template(cwd, thread_id), encoding="utf-8")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Locate or initialize the durable README for the current agent thread.",
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    for name in ("path", "ensure"):
        subparser = subparsers.add_parser(name)
        subparser.add_argument("--cwd", default=os.getcwd(), help="Workspace directory for the thread.")
        subparser.add_argument(
            "--thread-id",
            default=detect_thread_id() or "",
            help="Override the detected thread/session id.",
        )
        subparser.add_argument(
            "--root",
            default=str(default_memory_root()),
            help="Memory root directory. Defaults to THREAD_MEMORY_ROOT or ~/.thread-memory/threads.",
        )

    return parser.parse_args()


def main() -> int:
    args = parse_args()
    cwd = str(Path(args.cwd).expanduser().resolve())
    thread_id = args.thread_id.strip() or None
    root = Path(args.root).expanduser().resolve()
    path = readme_path(cwd, thread_id, root)

    if args.command == "ensure":
        ensure_readme(path, cwd, thread_id)

    print(path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
