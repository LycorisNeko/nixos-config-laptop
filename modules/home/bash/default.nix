{ pkgs, ... }:
{
  programs.bash = {
    enable = true;
    shellAliases = {
      "ff" = "clear && fastfetch";
      "fm" = "yazi";
      "nix-clean" = "sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot";
    };

    bashrcExtra = ''
      if [[ $- == *i* ]]; then
        fastfetch
        if [ -f "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh" ]; then
          source "/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh"
        fi
        if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
          exec niri-session -l
        fi
      fi
    '';

  };

  home.sessionVariables = {
    PRISMA_SCHEMA_ENGINE_BINARY = "${pkgs.prisma-engines}/bin/schema-engine";
    PRISMA_QUERY_ENGINE_BINARY = "${pkgs.prisma-engines}/bin/query-engine";
    PRISMA_QUERY_ENGINE_LIBRARY = "${pkgs.prisma-engines}/lib/libquery_engine.node";
    PRISMA_FMT_BINARY = "${pkgs.prisma-engines}/bin/prisma-fmt";
  };
}
