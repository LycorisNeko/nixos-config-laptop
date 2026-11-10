#!/usr/bin/env bash
set -euo pipefail

STATE_FILE="$HOME/.local/state/noctalia/settings.toml"
CONFIG_FILE="$HOME/.config/noctalia/config.toml"
CACHE_DIR="$HOME/.cache"
mkdir -p "$CACHE_DIR"

# 1. 同步壁紙至 ~/.cache/current_wallpaper.png (供 hyprlock 作為鎖定畫面背景)
WALLPAPER=""
if [ -n "${NOCTALIA_WALLPAPER:-}" ] && [ -f "$NOCTALIA_WALLPAPER" ]; then
    WALLPAPER="$NOCTALIA_WALLPAPER"
fi

if [ -z "$WALLPAPER" ]; then
    WALLPAPER=$(noctalia msg wallpaper-get 2>/dev/null || true)
fi

if [ -z "$WALLPAPER" ] || [ ! -f "$WALLPAPER" ]; then
    if [ -f "$STATE_FILE" ]; then
        WALLPAPER=$(grep -m1 '^[[:space:]]*path[[:space:]]*=' "$STATE_FILE" 2>/dev/null | cut -d'"' -f2 || true)
    fi
fi

if [ -z "$WALLPAPER" ] || [ ! -f "$WALLPAPER" ]; then
    WALLPAPER="$HOME/.config/noctalia/wallpapers/wallpapers26.png"
fi

if [ -f "$WALLPAPER" ]; then
    ln -sf "$WALLPAPER" "$CACHE_DIR/current_wallpaper.png"
fi

# 2. 同步頭像至 ~/.face 與 ~/.cache/current_avatar.png (供 hyprlock 與桌面環境使用)
AVATAR=""
if [ -f "$STATE_FILE" ]; then
    AVATAR=$(grep -E '^[[:space:]]*avatar_path[[:space:]]*=' "$STATE_FILE" 2>/dev/null | cut -d'"' -f2 || true)
fi

if [ -z "$AVATAR" ] || [ ! -f "$AVATAR" ]; then
    if [ -f "$HOME/Pictures/帕秋莉Nixos.png" ]; then
        AVATAR="$HOME/Pictures/帕秋莉Nixos.png"
    fi
fi

if [ -n "$AVATAR" ] && [ -f "$AVATAR" ]; then
    ln -sf "$AVATAR" "$HOME/.face"
    ln -sf "$AVATAR" "$CACHE_DIR/current_avatar.png"
fi
