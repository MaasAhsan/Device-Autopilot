---
description: Open a URL or search in Chrome, Edge, Firefox, Brave, Opera GX, Safari, or the default browser.
---

Run Device Autopilot.

Windows:

```powershell
powershell -ExecutionPolicy Bypass -File "REPO_OR_SKILL/scripts/open_web.ps1" -Search "TEXT" -Engine youtube -Browser opera-gx
```

macOS/Linux:

```bash
bash REPO_OR_SKILL/scripts/open_web.sh --search "TEXT" --engine youtube --browser default
```

Use `-Url` / `--url` when they gave a link. Use their browser name when they named one.
