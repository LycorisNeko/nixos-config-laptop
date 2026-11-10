{ pkgs, ... }:
{
  # 關閉自動空閒守護行程（防止閱覽、觀影或工作時無操作自動降低亮度、鎖屏或熄滅螢幕）
  # 螢幕保持常亮，支援以 Mod + Shift + L 手動鎖定畫面，或筆電合蓋觸發睡眠
  services.hypridle = {
    enable = false;
  };
}
