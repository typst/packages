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
        {
          system,
          config,
          pkgs,
          ...
        }:
        let
          xcharter = pkgs.callPackage ./xcharter.nix { };
          fontPackages = pkgs.symlinkJoin {
            name = "typst-fonts";
            paths = with pkgs; [
              noto-fonts
              open-sans
              jetbrains-mono
              xcharter
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
            typship = pkgs.rustPlatform.buildRustPackage rec {
              pname = "typship";
              version = "v0.4.1";
              src = pkgs.fetchFromGitHub {
                owner = "sjfhsjfh";
                repo = pname;
                rev = version;
                hash = "sha256-e7jGc/ENVEMGzXl+sidzNBFy+qZo9+ClRPYhsXtnyD8=";
              };
              nativeBuildInputs = with pkgs; [
                pkg-config
                openssl
                openssl.dev
                perl
              ];
              PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
              useFetchCargoVendor = true;
              cargoHash = "sha256-lRB+GL5dgl22B+qBZV273V9tavGu5HqK2Z9JFyqVoK8=";
            };
          };
          devShells.default = pkgs.mkShell {
            packages = with pkgs; [
              typst
              typstyle
              tinymist
              just
              typos
              svu
            ];

            shellHook = ''
              ${config.pre-commit.installationScript}
            '';

            TYPST_FONT_PATHS = fontPackages;
          };
        };
    };
}
