# wallpapers - Desktop wallpaper collection

{ config, lib, ... }:

{
  xdg.configFile."noctalia/wallpapers" = {
    source = builtins.filterSource (path: type:
      type == "directory" || (type == "regular" && lib.hasSuffix ".nix" path == false)
    ) ../wallpapers;
    recursive = true;
    force = true;
  };
}
