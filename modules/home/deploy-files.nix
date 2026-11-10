{ lib, ... }:
{
  home.file.".local/bin/noctalia-sync" = {
    source = ../scripts/noctalia-sync.sh;
    executable = true;
  };
  home.file.".local/bin/noctalia-sync.sh" = {
    source = ../scripts/noctalia-sync.sh;
    executable = true;
  };
  home.file.".local/bin/niri-screenshot.sh" = {
    source = ../scripts/niri-screenshot.sh;
    executable = true;
  };
  home.file.".local/bin/captureFullscreen.sh" = {
    source = ../scripts/captureFullscreen.sh;
    executable = true;
  };
  home.file.".local/bin/captureSelectArea.sh" = {
    source = ../scripts/captureSelectArea.sh;
    executable = true;
  };

  # 确保初次构建或切换后，~/.face 与壁纸缓存立即就绪供 hyprlock 使用
  home.activation.initLockscreenSync = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD mkdir -p $HOME/.cache
    if [ ! -e "$HOME/.face" ] && [ -f "$HOME/Pictures/帕秋莉Nixos.png" ]; then
      $DRY_RUN_CMD ln -sf "$HOME/Pictures/帕秋莉Nixos.png" "$HOME/.face"
    fi
    if [ ! -e "$HOME/.cache/current_wallpaper.png" ] && [ -f "$HOME/.config/noctalia/wallpapers/wallpapers26.png" ]; then
      $DRY_RUN_CMD ln -sf "$HOME/.config/noctalia/wallpapers/wallpapers26.png" "$HOME/.cache/current_wallpaper.png"
    fi
  '';

  # GitHub 用户信息与凭据助手配置
  home.file.".gitconfig" = {
    force = true;
    text = ''
      [user]
        name = LycorisNeko
        email = lycorisneko2023@gmail.com
      [credential]
        helper = store
    '';
  };
}
