from __future__ import annotations

import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "scripts" / "thread_memory.py"
THREAD_ENV_VARS = (
    "THREAD_MEMORY_ID",
    "CODEX_THREAD_ID",
    "CLAUDE_SESSION_ID",
    "CLAUDE_CONVERSATION_ID",
    "GEMINI_SESSION_ID",
    "OPENCODE_SESSION_ID",
)


class ThreadMemoryCliTests(unittest.TestCase):
    def run_cli(self, *args: str, env: dict[str, str] | None = None) -> subprocess.CompletedProcess[str]:
        merged_env = os.environ.copy()
        for name in THREAD_ENV_VARS:
            merged_env.pop(name, None)
        if env:
            merged_env.update(env)
        return subprocess.run(
            [sys.executable, str(SCRIPT), *args],
            check=True,
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            env=merged_env,
        )

    def test_ensure_creates_thread_readme(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            cwd = Path(tmp) / "project"
            root = (Path(tmp) / "memory").resolve()
            cwd.mkdir()

            result = self.run_cli("ensure", "--cwd", str(cwd), "--thread-id", "abc/123", "--root", str(root))
            path = Path(result.stdout.strip())

            self.assertEqual(path, root / "thread-abc-123" / "README.md")
            self.assertTrue(path.exists())
            text = path.read_text(encoding="utf-8")
            self.assertIn("# Thread Memory", text)
            self.assertIn("- Thread ID: `abc/123`", text)
            self.assertIn("## Current Objective", text)
            self.assertIn("## Open Questions", text)

    def test_path_does_not_create_readme(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            cwd = Path(tmp) / "project"
            root = (Path(tmp) / "memory").resolve()
            cwd.mkdir()

            result = self.run_cli("path", "--cwd", str(cwd), "--root", str(root))
            path = Path(result.stdout.strip())

            self.assertFalse(path.exists())
            self.assertIn("workspace-project-", str(path))

    def test_thread_memory_id_env_is_used(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            cwd = Path(tmp) / "project"
            root = (Path(tmp) / "memory").resolve()
            cwd.mkdir()

            result = self.run_cli(
                "ensure",
                "--cwd",
                str(cwd),
                "--root",
                str(root),
                env={"THREAD_MEMORY_ID": "session 42"},
            )

            self.assertEqual(Path(result.stdout.strip()), root / "thread-session-42" / "README.md")


if __name__ == "__main__":
    unittest.main()
