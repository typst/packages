{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    typst-packages = {
      url = "github:typst/packages";
      flake = false;
    };
    typst-nix = {
      url = "github:misterio77/typst-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.typst-packages.follows = "typst-packages";
    };
  };
  outputs =
    inputs:
    inputs.parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin"
        "x86_64-linux"
      ];
      imports = [ inputs.pre-commit-hooks.flakeModule ];
      perSystem =
        { system
        , config
        , pkgs
        , ...
        }:
        let
          fontPackages = pkgs.symlinkJoin {
            name = "typst-fonts";
            paths = with pkgs; [
              noto-fonts
              open-sans
              jetbrains-mono
              charis-sil
            ];
          };
        in
        {
          pre-commit = {
            check.enable = true;
            settings.hooks = {
              nixfmt-rfc-style.enable = true;
              deadnix.enable = true;
              statix.enable = true;
              typstyle.enable = true;
            };
          };
          packages = {
            default = inputs.typst-nix.lib.${system}.mkTypstDerivation {
              name = "modern-uit-thesis";
              src = ./.;
              extraFonts = fontPackages;
              extraCompileFlags = [
                "--root"
                "./"
              ];
              mainFile = "template/thesis.typ";
              outputFile = "thesis.pdf";
              typstPackages = {
                preview = "${inputs.typst-packages}/packages/preview";
              };
            };
          };
          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              typst
              typstyle
              tinymist
              just
              typos
            ];

            shellHook = ''
              ${config.pre-commit.installationScript}
            '';

            TYPST_FONT_PATHS = fontPackages;
          };
        };
    };
}
