{ pkgs, ... }:
{
  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      set fish_greeting ""

      fastfetch
    '';

    loginShellInit = ''
      if status is-interactive
        if test -z "$DISPLAY" -a -z "$WAYLAND_DISPLAY" -a (tty) = "/dev/tty1"
          exec niri-session -l
        end
      end
    '';

    shellAliases = {
      ls = "eza --icons";
      ll = "eza -la --icons --git";
      lt = "eza --tree --icons";
      cat = "bat";
      v = "nvim";
      lg = "lazygit";

      ff = "clear && fastfetch";
      fm = "yazi";

      vm = "GDK_SCALE=1 GDK_DPI_SCALE=1 GDK_BACKEND=x11 virt-manager";

      # 一键清理历史构建并同步更新 bootloader 启动项
      nix-clean = "sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot";

    };

    plugins = [
      {
        name = "fzf-fish";
        src = pkgs.fishPlugins.fzf-fish.src;
      }
      {
        name = "autopair";
        src = pkgs.fishPlugins.autopair.src;
      }
    ];
  };
}
