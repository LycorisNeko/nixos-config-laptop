#!/usr/bin/env bash
SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SCREENSHOT_DIR"

# 建立時間戳記檔案以準確比對本次截圖產生的新檔案
MARKER=$(mktemp /tmp/screenshot_marker.XXXXXX)

case "$1" in
  screen) niri msg action screenshot-screen ;;
  *)      niri msg action screenshot ;;
esac

NEW_FILE=""
# 最長等待 60 秒（使用者框選區域需要時間，若按 Esc 取消則超時退出）
for i in {1..300}; do
  CANDIDATE=$(find "$SCREENSHOT_DIR" -maxdepth 1 -name "*.png" -newer "$MARKER" -type f 2>/dev/null | head -1)
  if [ -n "$CANDIDATE" ] && [ -s "$CANDIDATE" ]; then
    sleep 0.1
    NEW_FILE="$CANDIDATE"
    break
  fi
  sleep 0.2
done

rm -f "$MARKER"

if [ -n "$NEW_FILE" ]; then
  wl-copy < "$NEW_FILE" 2>/dev/null || true
  notify-send -a "Screenshot" "截圖已儲存並複製到剪貼簿" "$NEW_FILE" -i "$NEW_FILE" -u low 2>/dev/null || true
  swappy -f "$NEW_FILE"
fi
