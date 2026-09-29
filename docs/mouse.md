# Mouse (Claude Code)

Windows only for now. No Python.

## Loop

1. `mouse.ps1 screenshot` — look at the PNG
2. Decide one click or key
3. `mouse.ps1 click X Y` (or `type` / `key`)
4. Screenshot again
5. Stop after 3 misses, a security prompt, or the task is done

Do not spray clicks.

## Commands

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\mouse.ps1 status
powershell -ExecutionPolicy Bypass -File .\scripts\mouse.ps1 screenshot
powershell -ExecutionPolicy Bypass -File .\scripts\mouse.ps1 click 400 300
powershell -ExecutionPolicy Bypass -File .\scripts\mouse.ps1 type "hello"
powershell -ExecutionPolicy Bypass -File .\scripts\mouse.ps1 key "^t"
```

`key` uses [SendKeys](https://learn.microsoft.com/en-us/dotnet/api/system.windows.forms.sendkeys): `^` Ctrl, `+` Shift, `%` Alt, `{ENTER}`, `{TAB}`, `{ESC}`.

## Do not

- Click UAC / Windows security boxes
- Enter passwords
- Buy or send things unless the user just asked and is watching
