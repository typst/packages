{
  description = "ustc-proposal";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    typix = {
      url = "github:loqusion/typix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";

    typst-packages = {
      url = "github:typst/packages";
      flake = false;
    };

    fonts-popular-fonts = {
      url = "github:chengda/popular-fonts";
      flake = false;
    };

    fonts-scp_zh = {
      url = "github:StellarCN/scp_zh";
      flake = false;
    };

    fonts-pytorch = {
      url = "github:siaimes/pytorch";
      flake = false;
    };

    fonts-androidFront = {
      url = "github:Kangzhengwei/androidFront";
      flake = false;
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      typix,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        typixLib = typix.lib.${system};

        src = typixLib.cleanTypstSource ./.;
        commonArgs = {
          typstSource = "main.typ";

          fontPaths = [
            "${pkgs.font-awesome}/share/fonts/opentype"
            "${inputs.fonts-popular-fonts}"
            "${inputs.fonts-scp_zh}/fonts"
            "${inputs.fonts-pytorch}/fonts"
            "${inputs.fonts-androidFront}"
          ];

          virtualPaths = [
            # Add paths that must be locally accessible to typst here
            # {
            #   dest = "icons";
            #   src = "${inputs.font-awesome}/svgs/regular";
            # }
          ];
        };
        typstPackagesSrc = pkgs.symlinkJoin {
          name = "typst-packages-src";
          paths = [
            "${inputs.typst-packages}/packages"
            # More Typst packages can be added here
          ];
        };
        typstPackagesCache = pkgs.stdenvNoCC.mkDerivation {
          name = "typst-packages-cache";
          src = typstPackagesSrc;
          dontBuild = true;
          installPhase = ''
            mkdir -p "$out/typst/packages"
            cp -LR --reflink=auto --no-preserve=mode -t "$out/typst/packages" "$src"/*
          '';
        };

        # Compile a Typst project, *without* copying the result
        # to the current directory
        build-drv = typixLib.buildTypstProject (
          commonArgs
          // {
            inherit src;
            XDG_CACHE_HOME = typstPackagesCache;
          }
        );

        # Compile a Typst project, and then copy the result
        # to the current directory
        build-script = typixLib.buildTypstProjectLocal (
          commonArgs
          // {
            inherit src;
            XDG_CACHE_HOME = typstPackagesCache;
          }
        );

        # Watch a project and recompile on changes
        watch-script = typixLib.watchTypstProject commonArgs;
      in
      {
        checks = {
          inherit build-drv build-script watch-script;
        };

        packages.default = build-drv;

        apps = rec {
          default = watch;
          build = flake-utils.lib.mkApp {
            drv = build-script;
          };
          watch = flake-utils.lib.mkApp {
            drv = watch-script;
          };
        };

        devShells.default = typixLib.devShell {
          inherit (commonArgs) fontPaths virtualPaths;
          packages = [
            # WARNING: Don't run `typst-build` directly, instead use `nix run .#build`
            # See https://github.com/loqusion/typix/issues/2
            # build-script
            watch-script
            # More packages can be added here, like typstfmt
            # pkgs.typstfmt
          ];
        };
      }
    );
}
