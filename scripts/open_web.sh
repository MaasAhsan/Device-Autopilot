#!/usr/bin/env bash
# Open a URL or web search on macOS / Linux.
#   ./scripts/open_web.sh --url https://example.com --browser chrome
#   ./scripts/open_web.sh --search "cats" --engine youtube --browser default

set -euo pipefail

URL=""
SEARCH=""
ENGINE="google"
BROWSER="default"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --url) URL="${2:-}"; shift 2 ;;
    --search) SEARCH="${2:-}"; shift 2 ;;
    --engine) ENGINE="${2:-google}"; shift 2 ;;
    --browser) BROWSER="${2:-default}"; shift 2 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

urlencode() {
  python3 -c 'import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))' "$1" 2>/dev/null ||
    python -c 'import urllib.parse,sys; print(urllib.parse.quote(sys.argv[1]))'
}

if [[ -n "$SEARCH" ]]; then
  Q="$(urlencode "$SEARCH")"
  case "${ENGINE,,}" in
    youtube) TARGET="https://www.youtube.com/results?search_query=${Q}" ;;
    bing) TARGET="https://www.bing.com/search?q=${Q}" ;;
    duckduckgo) TARGET="https://duckduckgo.com/?q=${Q}" ;;
    *) TARGET="https://www.google.com/search?q=${Q}" ;;
  esac
elif [[ -n "$URL" ]]; then
  TARGET="$URL"
  [[ "$TARGET" =~ ^https?:// ]] || TARGET="https://$TARGET"
else
  echo "pass --url or --search" >&2
  exit 2
fi

open_default() {
  if command -v open >/dev/null 2>&1; then
    open "$TARGET"
  else
    xdg-open "$TARGET" >/dev/null 2>&1
  fi
}

B="${BROWSER,,}"
if [[ "$B" == "default" || -z "$B" ]]; then
  open_default
  echo "ok: default browser"
  echo "url: $TARGET"
  exit 0
fi

# macOS app names
if command -v open >/dev/null 2>&1 && [[ "$(uname -s)" == "Darwin" ]]; then
  case "$B" in
    chrome|google-chrome) APP="Google Chrome" ;;
    firefox) APP="Firefox" ;;
    brave) APP="Brave Browser" ;;
    edge) APP="Microsoft Edge" ;;
    safari) APP="Safari" ;;
    opera) APP="Opera" ;;
    opera-gx|operagx) APP="Opera GX" ;;
    *) APP="" ;;
  esac
  if [[ -n "$APP" ]] && open -a "$APP" "$TARGET" 2>/dev/null; then
    echo "ok: $APP"
    echo "url: $TARGET"
    exit 0
  fi
fi

# Linux binaries
case "$B" in
  chrome|google-chrome) BINS=(google-chrome google-chrome-stable chromium chromium-browser) ;;
  firefox) BINS=(firefox) ;;
  brave) BINS=(brave brave-browser) ;;
  edge) BINS=(microsoft-edge microsoft-edge-stable) ;;
  opera) BINS=(opera) ;;
  opera-gx|operagx) BINS=(opera) ;;
  *) BINS=() ;;
esac
for bin in "${BINS[@]:-}"; do
  if command -v "$bin" >/dev/null 2>&1; then
    "$bin" "$TARGET" >/dev/null 2>&1 &
    echo "ok: $bin"
    echo "url: $TARGET"
    exit 0
  fi
done

echo "warn: browser '$BROWSER' not found; using default"
open_default
echo "ok: default browser"
echo "url: $TARGET"
