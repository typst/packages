{
  nixConfig = {
    extra-substituters = "https://cache.garnix.io";
    extra-trusted-public-keys = "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=";
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default";
    parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    press = {
      url = "github:RossSmyth/press";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    inputs:
    inputs.parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;
      imports = [ inputs.pre-commit-hooks.flakeModule ];
      perSystem =
        {
          system,
          config,
          pkgs,
          ...
        }:
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [ (import inputs.press) ];
          };

          pre-commit = {
            check.enable = true;
            settings.hooks = {
              nixfmt-rfc-style = {
                enable = true;
                stages = [ "pre-push" ];
              };
              typstyle = {
                enable = true;
                stages = [ "pre-push" ];
              };
            };
          };

          packages = import ./nix/packages { inherit pkgs; } // {
            default = config.packages.thesis;
          };

          devShells.default = pkgs.mkShellNoCC {
            name = "thesis";
            packages = with pkgs; [
              # Typst
              typst
              typstyle
              tinymist
              typship

              # Utils
              typos
              sd
            ];

            TYPST_FONT_PATHS = pkgs.symlinkJoin {
              name = "typst-fonts";
              paths = with pkgs; [
                noto-fonts
                open-sans
                jetbrains-mono
                config.packages.xcharter
              ];
            };

            shellHook = ''
              ${config.pre-commit.installationScript}
            '';
          };
        };
    };
}
