{ pkgs, config, ... }:
{
  programs.hyprlock = {
    enable = true;

    settings = {
      general = {
        disable_loading_bar = false;
        hide_cursor = true;
        grace = 0;
        no_fade_in = false;
        no_fade_out = false;
        immediate_render = true;
      };

      background = [
        {
          monitor = "";
          path = "${config.home.homeDirectory}/.cache/current_wallpaper.png";
          color = "rgba(25, 20, 20, 1.0)";
          blur_passes = 3;
          blur_size = 7;
          brightness = 0.6;
          contrast = 1.0;
          vibrancy = 0.2;
          vibrancy_darkness = 0.1;
        }
      ];

      # Clock
      label = [
        {
          monitor = "";
          text = ''cmd[update:1000] echo "$(date +"%H:%M")"'';
          color = "rgba(200, 211, 245, 1.0)"; # text #c8d3f5
          font_size = 96;
          font_family = "JetBrainsMono Nerd Font Bold";
          position = "0, 200";
          halign = "center";
          valign = "center";
          shadow_passes = 3;
          shadow_size = 10;
          shadow_color = "rgba(27, 29, 43, 0.8)";
        }

        # Date
        {
          monitor = "";
          text = ''cmd[update:60000] echo "$(date +"%A, %d %B %Y")"'';
          color = "rgba(130, 139, 184, 1.0)"; # subtext #828bb8
          font_size = 22;
          font_family = "JetBrainsMono Nerd Font";
          position = "0, 110";
          halign = "center";
          valign = "center";
          shadow_passes = 2;
          shadow_size = 8;
          shadow_color = "rgba(27, 29, 43, 0.8)";
        }

        # Greeting
        {
          monitor = "";
          text = "Welcome back, AnyNeko";
          color = "rgba(192, 153, 255, 0.9)"; # purple #c099ff
          font_size = 16;
          font_family = "JetBrainsMono Nerd Font";
          position = "0, 60";
          halign = "center";
          valign = "center";
        }

        # Caps Lock warning
        {
          monitor = "";
          text = ''cmd[update:250] grep -q '[1-9]' /sys/class/leds/*capslock*/brightness 2>/dev/null && echo "󰪛 Caps Lock is ON" || echo ""'';
          color = "rgba(255, 117, 127, 1.0)"; # red #ff757f
          font_size = 14;
          font_family = "JetBrainsMono Nerd Font Bold";
          position = "0, -180";
          halign = "center";
          valign = "center";
        }
      ];

      # Avatar
      image = [
        {
          monitor = "";
          path = "${config.home.homeDirectory}/.face";
          size = 100;
          rounding = -1; # fully circular
          border_size = 3;
          border_color = "rgba(130, 170, 255, 0.7)"; # blue #82aaff
          position = "0, -30";
          halign = "center";
          valign = "center";
          shadow_passes = 2;
          shadow_size = 10;
          shadow_color = "rgba(27, 29, 43, 0.6)";
        }
      ];

      # Password input
      input-field = [
        {
          monitor = "";
          size = "280, 52";
          position = "0, -140";
          halign = "center";
          valign = "center";

          outline_thickness = 2;
          dots_size = 0.25;
          dots_spacing = 0.2;
          dots_center = true;
          dots_rounding = -1;

          outer_color = "rgba(130, 170, 255, 0.5)"; # 柔和通透边框 (50% 不透明度)
          inner_color = "rgba(34, 36, 54, 0.65)"; # 舒适磨砂毛玻璃透光 (65% 不透明度)
          font_color = "rgba(200, 211, 245, 1.0)"; # text #c8d3f5
          fade_on_empty = true;
          fade_timeout = 1000;

          placeholder_text = ''<span foreground="##828bb8"> Password...</span>'';
          hide_input = false;
          rounding = 12;

          check_color = "rgba(195, 232, 141, 1.0)"; # green #c3e88d
          fail_color = "rgba(255, 117, 127, 1.0)"; # red #ff757f
          fail_text = "<i>$FAIL <b>($ATTEMPTS)</b></i>";
          fail_transition = 300;

          capslock_color = "rgba(255, 199, 119, 1.0)"; # yellow #ffc777
          numlock_color = "rgba(130, 170, 255, 1.0)"; # blue #82aaff
          bothlock_color = "rgba(255, 117, 127, 1.0)"; # red

          shadow_passes = 3;
          shadow_size = 12;
          shadow_color = "rgba(0, 0, 0, 0.4)";
        }
      ];
    };
  };
}
