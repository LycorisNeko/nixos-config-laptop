{
  description = "NixOS Laptop Configuration";

  inputs = {
    # 使用清华大学镜像源
    nixpkgs.url = "git+https://mirrors.tuna.tsinghua.edu.cn/git/nixpkgs.git?ref=nixos-unstable";

    # 使用官方 GitHub URL，不经过第三方代理
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
      url = "github:epireyn/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/nur";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs =
    inputs@{
      nixpkgs,
      home-manager,
      nixvim,
      nur,
      ...
    }:
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./modules/system/default.nix
          ./hardware-configuration.nix
          inputs.niri.nixosModules.niri

          # 系统层级配置与 Overlay 注入
          (
            { pkgs, ... }:
            {
              # 保持 overlays 为空，避免全局 overlay 篡改底层包导致 python3 等基础库的缓存哈希失效并引发本地漫长重编译
              nixpkgs.overlays = [ ];

              # 忽略/放行 GTK2 的 broken 標記
              nixpkgs.config = {
                problems.handlers = {
                  "gtk+".broken = "ignore";
                };
              };
            }
          )

          # Home Manager 模块配置
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;

              extraSpecialArgs = {
                inherit nixvim inputs;
              };

              users.anyneko = import ./modules/home/default.nix;
              backupFileExtension = "backup";

              sharedModules = [
                nixvim.homeModules.nixvim
                inputs.noctalia.homeModules.default
              ];
            };
          }
        ];
      };
    };
}
