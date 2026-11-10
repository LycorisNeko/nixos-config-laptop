{ pkgs, ... }:
{
  home.packages = with pkgs; [
    awww
    papirus-icon-theme
    adw-gtk3
    waypaper

    pavucontrol
    networkmanagerapplet
    nwg-drawer
    nwg-menu

    lf

    gthumb
    postman
    spotify
    zathura

    # Apps consolidated from single-file modules
    (blender.override { cudaSupport = true; })
    polychromatic # 雷蛇设备 RGB 灯效与性能图形化控制工具 (OpenRazer GUI)
    hmcl
    obsidian
    netease-cloud-music-gtk
    telegram-desktop
    tor-browser

    # Prisma
    prisma-engines

    # hypr
    wlr-randr # display management

    kitty

    libreoffice-stable
    antigravity-cli

    # Screenshot tools
    grim
    slurp
    swappy
    grimblast
    imagemagick
    libnotify

    openssl
    bitwig-studio

  ];

  programs.claude-code.enable = true;
}
