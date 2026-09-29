# Device Autopilot

Open a real browser from **Claude Code**, then move the **mouse**, click, and type (Windows).

Say:

> open youtube and search for lo-fi beats

or:

> open chrome and go to github.com

The agent runs a small script on **your computer**. It does not work in claude.ai / ChatGPT-in-the-browser. Those sites cannot touch your mouse.

## Install (Windows)

```powershell
git clone https://github.com/YOURUSER/device-autopilot.git
cd device-autopilot
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

That copies the skill to `%USERPROFILE%\.claude\skills\device-autopilot`.

Start a **new** Claude Code session and try:

```text
open youtube and search for cats
```

Self-test without Claude:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\open_web.ps1 -Search "cats" -Engine youtube -Browser opera-gx
powershell -ExecutionPolicy Bypass -File .\scripts\mouse.ps1 status
powershell -ExecutionPolicy Bypass -File .\scripts\mouse.ps1 screenshot
```

Mouse docs: [docs/mouse.md](docs/mouse.md).

## Install (macOS / Linux)

```bash
git clone https://github.com/YOURUSER/device-autopilot.git
cd device-autopilot
chmod +x install.sh scripts/open_web.sh
./install.sh
```

```bash
./scripts/open_web.sh --search "cats" --engine youtube --browser default
```

## What it can open

| Flag | Values |
|---|---|
| `-Browser` / `--browser` | `default`, `chrome`, `edge`, `firefox`, `brave`, `opera-gx`, `opera`, `safari` |
| `-Engine` / `--engine` | `youtube`, `google`, `bing`, `duckduckgo` |
| `-Url` / `--url` | any `https://...` page |
| `-Search` / `--search` | words to search |

If the named browser is missing, it falls back to the system default.

## Claude Code plugin (optional)

This repo is also a plugin (`/.claude-plugin/plugin.json`).

```text
/plugin install .
```

from the repo folder, or add the GitHub repo as a marketplace after you publish it.

## Limits

- The **model** cannot open apps by itself. The **script on your PC** can.
- Cloud chat websites stay link-only.
- No passwords, payments, or hidden automation.

## License

MIT
