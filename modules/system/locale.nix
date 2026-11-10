{ ... }:
{
  time.timeZone = "Asia/Taipei";

  # 将硬件时钟（RTC）设为本地时间，避免 Windows 与 Linux 双系统切换时出现时钟不同步/互相改写的问题
  time.hardwareClockInLocalTime = true;

  i18n = {
    defaultLocale = "zh_TW.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "zh_TW.UTF-8";
      LC_IDENTIFICATION = "zh_TW.UTF-8";
      LC_MEASUREMENT = "zh_TW.UTF-8";
      LC_MONETARY = "zh_TW.UTF-8";
      LC_NAME = "zh_TW.UTF-8";
      LC_NUMERIC = "zh_TW.UTF-8";
      LC_PAPER = "zh_TW.UTF-8";
      LC_TELEPHONE = "zh_TW.UTF-8";
      LC_TIME = "zh_TW.UTF-8";
    };
    supportedLocales = [
      "zh_TW.UTF-8/UTF-8"
      "zh_HK.UTF-8/UTF-8"
      "zh_CN.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
    ];
  };
}
