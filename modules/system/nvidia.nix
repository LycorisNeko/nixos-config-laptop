{ config, lib, pkgs, ... }:
{
  # Razer Blade 15 Base (Early 2021) — Intel Comet Lake-H UHD Graphics + NVIDIA RTX 3070 Laptop GPU

  # 1. 启用 NVIDIA 专有驱动
  services.xserver.videoDrivers = [ "nvidia" ];

  # 2. 硬件图形加速与 VAAPI 编解码器支持
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-media-driver # iHD 驱动：Intel Comet Lake-H 硬件编解码
      intel-vaapi-driver # i965 驱动回退
      vaapiVdpau
      libvdpau-va-gl
      nvidia-vaapi-driver # NVIDIA NVDEC 硬件加速
    ];
  };

  # 3. NVIDIA 驱动与 PRIME Offload 模式配置
  hardware.nvidia = {
    # 启用 KMS (Kernel Mode Setting)
    modesetting.enable = true;

    # 细粒度动态电源管理（Ampere 架构 RTX 3070 支持空闲时自动切断独显供电，大幅延长续航）
    powerManagement.enable = true;
    powerManagement.finegrained = true;

    # 使用专有闭源驱动，保证 PRIME 动态切换、CUDA 与游戏兼容性
    open = false;

    # 启用 nvidia-settings GUI 工具
    nvidiaSettings = true;

    # 驱动版本使用稳定版
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # PRIME 双显卡混合渲染配置
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true; # 提供 nvidia-offload 启动包装脚本
      };

      # Intel UHD Graphics: PCI 0:2:0
      intelBusId = "PCI:0:2:0";
      # NVIDIA GeForce RTX 3070 Laptop GPU: PCI 1:0:0
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # 4. 会话环境变量：默认使用 Intel 核显驱动进行桌面与视频硬件解码，降低功耗发热
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };
}
