#!/usr/bin/env bash
set -euo pipefail

REPO="${THREAD_MEMORY_REPO:-kooroEZP/thread-memory}"
REF="${THREAD_MEMORY_REF:-main}"
SOURCE_DIR="${THREAD_MEMORY_SOURCE_DIR:-}"

TARGETS=()

usage() {
  cat <<'EOF'
Usage: install.sh [--codex] [--claude] [--gemini] [--opencode] [--all] [--source DIR] [--repo OWNER/REPO] [--ref REF]

Examples:
  curl -fsSL https://raw.githubusercontent.com/kooroEZP/thread-memory/main/install.sh | bash -s -- --codex
  curl -fsSL https://raw.githubusercontent.com/kooroEZP/thread-memory/main/install.sh | bash -s -- --claude
  ./install.sh --source . --all

Environment:
  THREAD_MEMORY_REPO      GitHub owner/repo. Default: kooroEZP/thread-memory
  THREAD_MEMORY_REF       Git ref to install. Default: main
  THREAD_MEMORY_SOURCE_DIR Local checkout to install from.
EOF
}

log() {
  printf 'thread-memory: %s\n' "$*" >&2
}

die() {
  printf 'thread-memory: error: %s\n' "$*" >&2
  exit 1
}

add_target() {
  local target="$1"
  local existing
  for existing in ${TARGETS[@]+"${TARGETS[@]}"}; do
    if [ "$existing" = "$target" ]; then
      return
    fi
  done
  TARGETS+=("$target")
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --codex)
      add_target codex
      shift
      ;;
    --claude)
      add_target claude
      shift
      ;;
    --gemini)
      add_target gemini
      shift
      ;;
    --opencode)
      add_target opencode
      shift
      ;;
    --all)
      add_target codex
      add_target claude
      add_target gemini
      add_target opencode
      shift
      ;;
    --source)
      [ "$#" -ge 2 ] || die "--source requires a directory"
      SOURCE_DIR="$2"
      shift 2
      ;;
    --repo)
      [ "$#" -ge 2 ] || die "--repo requires OWNER/REPO"
      REPO="$2"
      shift 2
      ;;
    --ref)
      [ "$#" -ge 2 ] || die "--ref requires a git ref"
      REF="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "unknown argument: $1"
      ;;
  esac
done

if [ "${#TARGETS[@]}" -eq 0 ]; then
  add_target codex
fi

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "missing required command: $1"
}

copy_dir() {
  local src="$1"
  local dest="$2"
  local tmp="${dest}.tmp.$$"

  [ -d "$src" ] || die "source directory does not exist: $src"
  mkdir -p "$(dirname "$dest")"
  rm -rf "$tmp"
  cp -R "$src" "$tmp"
  rm -rf "$tmp/.git" "$tmp/.DS_Store"
  rm -rf "$dest"
  mv "$tmp" "$dest"
}

write_managed_block() {
  local file="$1"
  local host="$2"

  mkdir -p "$(dirname "$file")"
  python3 - "$file" "$host" <<'PY'
from __future__ import annotations

import sys
from pathlib import Path

path = Path(sys.argv[1]).expanduser()
host = sys.argv[2]
start = "<!-- thread-memory:start -->"
end = "<!-- thread-memory:end -->"
block = f"""{start}
## Thread Memory

Before any substantive reply in {host}, use the `thread-memory` skill:

- Run `thread-memory ensure --cwd "$PWD"` and read the returned `README.md` before analysis, coding, or detailed answers.
- Before finishing a substantive turn, update that same `README.md` with the current objective, durable context, decisions, important files, recent progress, next steps, and open questions.
- In the final response, mention the exact memory file path that was updated.
{end}
"""

text = path.read_text(encoding="utf-8") if path.exists() else ""
if start in text and end in text:
    before, rest = text.split(start, 1)
    _, after = rest.split(end, 1)
    text = before.rstrip() + "\n\n" + block + after.lstrip("\n")
else:
    text = text.rstrip() + "\n\n" + block if text.strip() else block

path.write_text(text.rstrip() + "\n", encoding="utf-8")
PY
}

install_cli() {
  local root="$1"
  local bin_dir="${THREAD_MEMORY_BIN_DIR:-$HOME/.local/bin}"
  mkdir -p "$bin_dir"
  cp "$root/scripts/thread_memory.py" "$bin_dir/thread-memory"
  chmod +x "$bin_dir/thread-memory"
  log "installed CLI to $bin_dir/thread-memory"
}

install_codex() {
  local root="$1"
  local codex_home="${CODEX_HOME:-$HOME/.codex}"
  copy_dir "$root/skills/thread-memory" "$codex_home/skills/thread-memory"
  write_managed_block "$codex_home/AGENTS.md" "Codex"
  install_cli "$root"
  log "installed Codex skill to $codex_home/skills/thread-memory"
}

install_claude() {
  local root="$1"
  local claude_home="${CLAUDE_HOME:-$HOME/.claude}"
  copy_dir "$root/skills/thread-memory" "$claude_home/skills/thread-memory"
  write_managed_block "$claude_home/CLAUDE.md" "Claude Code"
  install_cli "$root"
  log "installed Claude skill to $claude_home/skills/thread-memory"
}

install_gemini() {
  local root="$1"
  local gemini_home="${GEMINI_HOME:-$HOME/.gemini}"
  copy_dir "$root" "$gemini_home/extensions/thread-memory"
  install_cli "$root"
  log "installed Gemini extension to $gemini_home/extensions/thread-memory"
}

install_opencode() {
  local root="$1"
  local opencode_dir="${OPENCODE_CONFIG_DIR:-$HOME/.config/opencode}"
  local plugin_dir="$opencode_dir/plugins/thread-memory"
  local config_file="$opencode_dir/opencode.json"

  copy_dir "$root" "$plugin_dir"
  mkdir -p "$opencode_dir"
  python3 - "$config_file" "$plugin_dir" <<'PY'
from __future__ import annotations

import json
import sys
from pathlib import Path

config_path = Path(sys.argv[1]).expanduser()
plugin_path = str(Path(sys.argv[2]).expanduser())

if config_path.exists() and config_path.read_text(encoding="utf-8").strip():
    try:
        data = json.loads(config_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError:
        print(f"thread-memory: warning: {config_path} is not plain JSON; add {plugin_path!r} to its plugin array manually", file=sys.stderr)
        raise SystemExit(0)
else:
    data = {}

plugins = data.get("plugin", [])
if isinstance(plugins, str):
    plugins = [plugins]
elif not isinstance(plugins, list):
    plugins = []

if plugin_path not in plugins:
    plugins.append(plugin_path)
data["plugin"] = plugins

config_path.parent.mkdir(parents=True, exist_ok=True)
config_path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
PY
  install_cli "$root"
  log "installed OpenCode plugin to $plugin_dir"
}

prepare_source() {
  if [ -n "$SOURCE_DIR" ]; then
    local src
    src="$(cd "$SOURCE_DIR" && pwd)"
    [ -f "$src/scripts/thread_memory.py" ] || die "--source does not look like thread-memory repo: $SOURCE_DIR"
    printf '%s\n' "$src"
    return
  fi

  require_cmd curl
  require_cmd tar

  local tmp
  tmp="$(mktemp -d)"
  local archive="$tmp/source.tar.gz"
  local root="$tmp/source"
  mkdir -p "$root"
  log "downloading https://github.com/$REPO/archive/$REF.tar.gz"
  curl -fsSL "https://github.com/$REPO/archive/$REF.tar.gz" -o "$archive"
  tar -xzf "$archive" --strip-components=1 -C "$root"
  [ -f "$root/scripts/thread_memory.py" ] || die "downloaded archive does not contain scripts/thread_memory.py"
  printf '%s\n' "$root"
}

require_cmd python3
SOURCE_ROOT="$(prepare_source)"

for target in "${TARGETS[@]}"; do
  case "$target" in
    codex) install_codex "$SOURCE_ROOT" ;;
    claude) install_claude "$SOURCE_ROOT" ;;
    gemini) install_gemini "$SOURCE_ROOT" ;;
    opencode) install_opencode "$SOURCE_ROOT" ;;
    *) die "unsupported target: $target" ;;
  esac
done

log "done"
