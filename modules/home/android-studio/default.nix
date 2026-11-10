{ pkgs, ... }:
{
  # Android Studio 官方集成开发环境
  home.packages = with pkgs; [
    android-studio
  ];

  # 插件生态与汉化配置说明：
  # 官方中文语言包 (Chinese Simplified Language Pack)：
  # - 插件 ID：com.intellij.zh
  # - 安装方式：启动 Android Studio -> 欢迎界面「Plugins」（或 Settings -> Plugins）->
  #   在 Marketplace 搜索「Chinese (Simplified) Language Pack」点击 Install 并重启即可完成完整中文化。
}
