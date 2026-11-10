{ config, ... }:
{
  imports = [
    ./rofi/default.nix
    ./fcitx5/default.nix              # fcitx5 輸入法框架
    ./window-managers/default.nix     # window managers
    ./waybar/default.nix
    ./gtk/default.nix
    ./wallpapers
    ./foot/default.nix
    ./bash/default.nix
    ./nixvim/default.nix
    ./swappy/default.nix
    ./packages.nix
    ./virt-manager/default.nix
    ./starship/default.nix
    ./tmux/default.nix
    ./cli/default.nix
    ./discord/default.nix
    ./yazi/default.nix
    ./noctalia/default.nix
    ./tools.nix
    ./obs-studio/default.nix
    ./bottles/default.nix
    ./qq/default.nix
    ./wechat/default.nix
    ./xdg-portal.nix
    ./chrome/default.nix
    ./file-roller/default.nix
    ./fish/default.nix
    ./deploy-files.nix
    ./devshell/default.nix
    ./mpv/default.nix
    ./motrix/default.nix
    ./android-studio/default.nix
    ./vscode/default.nix
  ];


  xdg = {
    enable = true;
    userDirs.enable = false;
    desktopEntries.cups = {
      name = "Manage Printing";
      noDisplay = true;
    };
  };

  home.sessionPath = [ "$HOME/.local/bin" ];
  home.sessionVariables = {
    GOPATH = "${config.xdg.dataHome}/go";
    PYTHON_HISTORY = "${config.xdg.stateHome}/python/history";
    NPM_CONFIG_CACHE = "${config.xdg.cacheHome}/npm";
    NPM_CONFIG_USERCONFIG = "${config.xdg.configHome}/npm/npmrc";
    WGETRC = "${config.xdg.configHome}/wget/wgetrc";
    LESSHISTFILE = "${config.xdg.stateHome}/less/history";
    CARGO_HOME = "${config.xdg.dataHome}/cargo";
    GNUPGHOME = "${config.xdg.dataHome}/gnupg";

    # fcitx5 輸入法與 Wayland IME 環境變數設定
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "@im=fcitx";
    SDL_IM_MODULE = "fcitx";
    GLFW_IM_MODULE = "ibus";

    # 使 Electron / Chromium 應用原生走 Wayland 並完整支援 IME
    NIXOS_OZONE_WL = "1";
  };

  xdg.configFile."wget/wgetrc".text = ''
    continue = on
  '';

  home.username = "anyneko";
  home.homeDirectory = "/home/anyneko";
  home.stateVersion = "25.11";

}
