# Installing Thread Memory for OpenCode

Add the plugin to `opencode.json`:

```json
{
  "plugin": ["thread-memory@git+https://github.com/kooroEZP/thread-memory.git"]
}
```

Restart OpenCode. The plugin registers the `skills/thread-memory` directory and injects the bootstrap instructions at the start of each session.

For a local checkout, use the installer:

```bash
./install.sh --source . --opencode
```
