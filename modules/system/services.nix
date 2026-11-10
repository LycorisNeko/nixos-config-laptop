{ pkgs, config, ... }:
{
  # 1. 啟用系統級 Niri 視窗管理器
  programs.niri.enable = true;

  # 2. 認證與登入配置 (方案 A: TTY 自動登入 anyneko，桌面由 hyprlock 進行密碼驗證)
  services.getty.autologinUser = "anyneko";
  security.pam.services.hyprlock = {};
  services.gnome.gnome-keyring.enable = true;

  # 3. 硬體與系統服務配置 (筆電電源管理、散熱與外設)
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;
  services.thermald.enable = true; # Intel CPU 溫控與散熱管理 (防止過熱降頻)
  hardware.openrazer.enable = true; # 雷蛇筆電鍵盤燈效與驅動支援
  hardware.bluetooth = {
    enable = true;
    settings = {
      General = {
        UserspaceHID = "true";
      };
      LE = {
        MinConnectionInterval = 7;
        MaxConnectionInterval = 9;
        ConnectionLatency = 0;
        SupervisionTimeout = 100;
      };
    };
  };

  services.blueman.enable = true;
  hardware.enableAllFirmware = true;
  services.tailscale.enable = true;

  programs.thunar.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;
  services.tumbler.enable = true;
  services.openssh.enable = true;

  security.polkit = {
    enable = true;
    extraConfig = ''
      polkit.addRule(function(action, subject) {
        if ((action.id == "org.freedesktop.udisks2.filesystem-mount" ||
             action.id == "org.freedesktop.udisks2.filesystem-mount-system" ||
             action.id == "org.freedesktop.udisks2.filesystem-mount-other-seat" ||
             action.id == "org.freedesktop.udisks2.encrypted-unlock" ||
             action.id == "org.freedesktop.udisks2.encrypted-unlock-system" ||
             action.id == "org.freedesktop.udisks2.eject-media" ||
             action.id == "org.freedesktop.udisks2.power-off-drive") &&
            subject.isInGroup("wheel")) {
          return polkit.Result.YES;
        }
      });
    '';
  };

  # 4. 資料庫配置
  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_17;
    settings = {
      timezone = "Asia/Singapore";
      log_timezone = "Asia/Singapore";
    };
    authentication = pkgs.lib.mkOverride 10 ''
      # TYPE  DATABASE  USER  ADDRESS     METHOD
      local   all       all               peer
      host    all       all   127.0.0.1/32  scram-sha-256
      host    all       all   ::1/128       scram-sha-256
    '';
    ensureDatabases = [
      "mydb"
      "anyneko"
    ];
    ensureUsers = [
      {
        name = "anyneko";
        ensureDBOwnership = true;
      }
    ];
  };

  # 5. 打印服務 (CUPS) 與 Epson 驱动（仅本地，关闭 Web UI）
  services.printing = {
    enable = true;
    webInterface = false; # 禁用 CUPS Web UI
    drivers = with pkgs; [
      epson-escpr
      epson-escpr2
      foomatic-db-ppds
    ];
    openFirewall = false; # 关闭防火墙打印端口暴露，只保留本地访问
    startWhenNeeded = true;
  };

  # 6. 扫描仪服务 (SANE) 与开源驱动方案 (eSCL / AirScan / WSD)
  # Epson WF-C5890 现代多功能一体机支持标准免驱 eSCL (AirScan) 与 WSD 协议。
  # 使用 sane-airscan 提供纯开源实现，无需安装闭源 epsonscan2 驱动与专有插件。
  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.sane-airscan ];
    openFirewall = true;
  };

  # 启用 Avahi (mDNS/DNS-SD)，供 SANE AirScan 自动发现局域网内的 Epson 扫描仪
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # 启用 ipp-usb：若通过 USB 直连，将一体机模拟为本地 eSCL/IPP 免驱扫描仪
  services.ipp-usb.enable = true;

  # Epson WF-C5890 USB 专属 udev 规则：确保设备节点分配至 lp/scanner 组，并唤起 ipp-usb 服务
  # 睡眠防秒醒 udev 规则：
  # - 默认禁用易误触 USB 设备唤醒（有线鼠标晃动、麦克风等）
  # - 白名单放行：雷蛇内建键盘/触控板 (VID 1532)、2.4G 无线键盘接收器 (3554:fa09) 与电源键唤醒
  # - 禁用以太网卡的自动唤醒属性
  services.udev.extraRules = ''
    ATTRS{idVendor}=="04b8", ATTRS{idProduct}=="11b6", MODE="0664", GROUP="lp", ENV{libsane_matched}="yes", TAG+="systemd", ENV{SYSTEMD_WANTS}+="ipp-usb.service"
    ACTION=="add|change", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTR{power/wakeup}="disabled"
    ACTION=="add|change", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="1532", ATTR{power/wakeup}="enabled"
    ACTION=="add|change", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="3554", ATTRS{idProduct}=="fa09", ATTR{power/wakeup}="enabled"
    ACTION=="add|change", SUBSYSTEM=="net", KERNEL=="en*", ATTR{device/power/wakeup}="disabled"
  '';

  # 7. 解决睡眠秒醒问题（保留电源键、开盖唤醒与键盘）：
  # - 确保 PWRB（电源键）、XHCI（USB 控制器）、LID/LID0（筆電開蓋感應）處於啟用狀態
  # - 禁用多餘的 PCIe/網卡廣播喚醒源
  systemd.services.disable-acpi-wakeup = {
    description = "Configure system sleep wakeup sources (keep lid, keyboard and power button)";
    wantedBy = [ "multi-user.target" "post-resume.target" ];
    after = [ "basic.target" "post-resume.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "configure-wakeup-sources" ''
        # 1. 確保電源鍵 (PWRB)、USB 主控 (XHCI) 與筆電開蓋 (LID/LID0) 保持啟用
        for target in PWRB XHCI LID LID0; do
          if grep -qE "^$target\s+.*\*disabled" /proc/acpi/wakeup; then
            echo "$target" > /proc/acpi/wakeup
          fi
        done

        # 2. 禁用除電源鍵、開蓋與 USB 之外的 ACPI 喚醒源（網卡廣播、PCIe 端口等）
        while read -r dev _ status _; do
          if [ "$status" = "*enabled" ] && [ "$dev" != "PWRB" ] && [ "$dev" != "XHCI" ] && [ "$dev" != "LID" ] && [ "$dev" != "LID0" ]; then
            echo "$dev" > /proc/acpi/wakeup
          fi
        done < /proc/acpi/wakeup

        # 3. 確保 USB 設備喚醒狀態：允許雷蛇鍵盤與指定接收器喚醒
        for dev_dir in /sys/bus/usb/devices/*; do
          if [ -f "$dev_dir/power/wakeup" ]; then
            vid=$(cat "$dev_dir/idVendor" 2>/dev/null || true)
            pid=$(cat "$dev_dir/idProduct" 2>/dev/null || true)
            if [ "$vid" = "1532" ] || ([ "$vid" = "3554" ] && [ "$pid" = "fa09" ]); then
              echo enabled > "$dev_dir/power/wakeup"
            else
              echo disabled > "$dev_dir/power/wakeup"
            fi
          fi
        done
      '';
    };
  };


  # 安装打印与扫描开源图形工具
  environment.systemPackages = with pkgs; [
    system-config-printer
    simple-scan # 开源文档扫描工具 (Document Scanner)
  ];
  # Cachix 与各镜像源二进制缓存（substituters 及 trusted-public-keys）统一由 modules/system/nix.nix 集中管理。

  systemd.oomd.enable = true;
}
