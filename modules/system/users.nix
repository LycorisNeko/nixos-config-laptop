{ pkgs, ... }:
{
  programs.fish.enable = true;

  users.users.anyneko = {
    isNormalUser = true;
    description = "AnyNeko";
    group = "anyneko"; # 明确指定主组名称
    extraGroups = [
      "networkmanager"
      "wheel"
      "video"
      "audio"
      "docker"
      "scanner" # SANE 扫描仪访问权限
      "lp"      # 打印机与复合扫描设备权限
      "libvirtd"
      "kvm"
      "storage"
    ];
    # shell = pkgs.bash;
    shell = pkgs.fish;
    homeMode = "711";
  };

  # 建立对应的同名主组
  users.groups.anyneko = {};
}