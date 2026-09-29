#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")" && pwd)"
DEST="${HOME}/.claude/skills/device-autopilot"
mkdir -p "${DEST}/scripts"
cp "${ROOT}/skills/device-autopilot/SKILL.md" "${DEST}/SKILL.md"
cp "${ROOT}/scripts/open_web.sh" "${DEST}/scripts/open_web.sh"
cp "${ROOT}/scripts/open_web.ps1" "${DEST}/scripts/open_web.ps1"
chmod +x "${DEST}/scripts/open_web.sh"
echo "Installed to ${DEST}"
echo "Open a new Claude Code session, then try: open youtube and search for cats"
