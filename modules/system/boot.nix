{ pkgs, ... }:
{
  boot.loader.systemd-boot = {
    enable = true;
    # 限制启动项保留最近 5 个版本，防止启动菜单过长并避免 /boot 分区被旧内核占满
    configurationLimit = 5;
    # 显式定义 Windows 启动入口
    extraEntries = {
      "windows.conf" = ''
        title Windows 11
        efi /EFI/Microsoft/Boot/bootmgfw.efi
        sort-key windows
      '';
    };
    # 自动从 Windows EFI 分区 (nvme0n1p1, UUID: 5A4E-34EF) 复制启动文件至 /boot
    extraInstallCommands = ''
      ${pkgs.coreutils}/bin/mkdir -p /boot/EFI
      WIN_ESP_MNT=$(${pkgs.coreutils}/bin/mktemp -d)
      if ${pkgs.util-linux}/bin/mount -t vfat -o ro /dev/disk/by-uuid/5A4E-34EF "$WIN_ESP_MNT" 2>/dev/null; then
        if [ -d "$WIN_ESP_MNT/EFI/Microsoft" ]; then
          ${pkgs.coreutils}/bin/cp -ru "$WIN_ESP_MNT/EFI/Microsoft" /boot/EFI/
        fi
        ${pkgs.util-linux}/bin/umount "$WIN_ESP_MNT" 2>/dev/null || true
      fi
      ${pkgs.coreutils}/bin/rm -rf "$WIN_ESP_MNT" 2>/dev/null || true

      # 禁用 systemd-boot 自动探测重复生成的 "Windows Boot Manager"，统一使用上述定义的 "Windows 11"
      if [ -f /boot/loader/loader.conf ]; then
        if ${pkgs.gnugrep}/bin/grep -q "auto-windows" /boot/loader/loader.conf; then
          ${pkgs.gnused}/bin/sed -i 's/^auto-windows.*/auto-windows false/' /boot/loader/loader.conf
        else
          echo "auto-windows false" >> /boot/loader/loader.conf
        fi
      fi
    '';
  };

  # 启动菜单倒计时 5 秒（默认选定并进入 NixOS，按任意键可切换至 Windows 11 等其他系统）
  boot.loader.timeout = 5;

  boot.loader.efi.canTouchEfiVariables = true;

  # 开机动画与 NixOS Logo 配置 (Plymouth)
  boot.plymouth = {
    enable = true;
    theme = "breeze";
    logo = "${pkgs.nixos-icons}/share/icons/hicolor/512x512/apps/nix-snowflake.png";
  };

  # 静默开机配置：隐藏终端日志输出与 initrd 冗余信息
  boot.consoleLogLevel = 0;

  # Early KMS: 在 initrd 阶段尽早加载 AMD 显卡驱动，确保 Plymouth 流畅无闪烁渲染
  boot.initrd.kernelModules = [ "amdgpu" ];

  boot.kernelParams = [
    "btusb.enable_autosuspend=0"
    # 静默开机参数：隐藏内核跑码、systemd 服务启动日志与终端闪烁光标
    "quiet"
    "splash"
    "boot.shell_on_fail"
    "loglevel=3"
    "rd.systemd.show_status=false"
    "rd.udev.log_level=3"
    "udev.log_priority=3"
    "systemd.show_status=false"
    "vt.global_cursor_default=0"
    # 彻底禁用主板厂商 (Dell) ACPI BGRT OEM 开机 Logo
    "bgrt_disable"
    "video=efifb:nobgrt"
  ];

  boot.kernelModules = [
    "ip_tables"
    "iptable_filter"
    "iptable_nat"
    "br_netfilter"
  ];

  boot.kernel.sysctl = {
    "net.core.default_qdisc" = "fq";
    "net.ipv4.tcp_congestion_control" = "bbr";
  };

  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;

  boot.supportedFilesystems = [
    "ntfs"
    "btrfs"
  ];

  services.fstrim.enable = true;
  zramSwap.enable = true;
}
