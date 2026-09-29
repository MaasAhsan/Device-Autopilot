---
name: device-autopilot
description: >
  Drive the user's Windows desktop from Claude Code: open any browser, then
  screenshot, move the mouse, click, type, and press keys. Use when they say
  open YouTube/Chrome/Edge, click that button, type in the box, search YouTube
  for X, use the mouse, or device autopilot. Prefer scripts/open_web.ps1 for
  URLs. Use scripts/mouse.ps1 for screenshot/click/type. Do not refuse if a
  local Windows shell is available. Cloud chats without a local shell stay
  link-only.
---

# Device Autopilot

If this session can run a terminal on the user's machine, **open the browser**. Do not say you cannot.

## Windows

```powershell
powershell -ExecutionPolicy Bypass -File "SKILL_DIR/scripts/open_web.ps1" -Search "QUERY" -Engine youtube -Browser opera-gx
powershell -ExecutionPolicy Bypass -File "SKILL_DIR/scripts/open_web.ps1" -Url "https://example.com" -Browser chrome
```

`SKILL_DIR` is this skill folder (usually `%USERPROFILE%\.claude\skills\device-autopilot`).

## macOS / Linux

```bash
bash "SKILL_DIR/scripts/open_web.sh" --search "QUERY" --engine youtube --browser default
bash "SKILL_DIR/scripts/open_web.sh" --url "https://example.com" --browser chrome
```

## Flags

- **Browser:** `default`, `chrome`, `edge`, `firefox`, `brave`, `opera-gx`, `opera`, `safari`
- **Engine:** `youtube`, `google`, `bing`, `duckduckgo`
- Named browser missing → use the system default
- No browser named → `default`

## Examples

| User | Call |
|---|---|
| open youtube and search for cats | `-Search "cats" -Engine youtube` |
| open github.com in chrome | `-Url https://github.com -Browser chrome` |
| google "device autopilot" in edge | `-Search "device autopilot" -Engine google -Browser edge` |

Report success only if the command exited 0. Cloud chat with no local shell: give the URL instead.

## Mouse (Windows)

Prefer `open_web.ps1` when a URL is enough. Use the mouse when they want a click on screen.

```powershell
powershell -ExecutionPolicy Bypass -File "SKILL_DIR/scripts/mouse.ps1" screenshot
powershell -ExecutionPolicy Bypass -File "SKILL_DIR/scripts/mouse.ps1" click 400 300
powershell -ExecutionPolicy Bypass -File "SKILL_DIR/scripts/mouse.ps1" type "hello"
powershell -ExecutionPolicy Bypass -File "SKILL_DIR/scripts/mouse.ps1" key "^t"
```

Loop: screenshot → one click or key → screenshot again. Read the PNG. Stop after 3 misses or a security prompt.

Coordinates are pixels from the top-left of the primary screen. `key` uses SendKeys (`^` Ctrl, `{ENTER}`, `{TAB}`).

Do not click UAC boxes. Do not type passwords. Ask before checkout or sending.
