{ pkgs, ... }:
{
  # Enable Java and set JAVA_HOME automatically
  programs.java.enable = true;

  # nix-ld：在 NixOS 上为非 Nix 打包的二进制与 manylinux wheel 提供标准的动态链接器 (/lib64/ld-linux-x86-64.so.2)
  # 彻底解决 pip / uv 安装包含 C/C++ 扩展的 Python 包（如 numpy, torch, pandas）时因缺少动态链接环境而触发本地漫长编译的问题
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib
      zlib
      fuse3
      icu
      zstd
      openssl
      curl
      expat
      glib
      libxml2
      libxslt
      libffi
      readline
      sqlite
    ];
  };

  environment.systemPackages = with pkgs; [
    # Android tools (adb, fastboot等，systemd 258+ 自动处理 uaccess 规则)
    android-tools
    # Git HTTPS 凭据通过 GNOME Keyring 安全保存，不写入明文文件。
    gitFull
    gnome-keyring

    # Core utils
    wget
    vim
    curl
    unzip
    zip
    btop
    python3
    ffmpeg
    pciutils
    nvtopPackages.nvidia # GPU 实时资源监控（支持 Intel 核显与 NVIDIA 独显）

    docker-compose

    wl-clipboard
    brightnessctl
    playerctl
    xdg-utils
    tree
    ntfs3g
    dosfstools
    hyprpolkitagent

    visidata

    # 遊戲轉譯層
    protonup-qt # Proton 版本管理工具

  ];
}
