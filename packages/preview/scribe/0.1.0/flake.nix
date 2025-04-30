{
  description = "scribe - Write math in ascii notation.";

  inputs = {
    nixpkgs.url    = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        scribe = pkgs.buildTypstPackage {
          pname   = "scribe";
          version = "0.1.0";
          src     = ./.;
        };
      in
      {
        packages.default = scribe;

        devShells.default = pkgs.mkShellNoCC {
          buildInputs = [
            pkgs.typst
            pkgs.tinymist
            scribe
          ];
        };

        checks.default = let
          quick-maths = pkgs.typstPackages.quick-maths_0_2_0;
        in pkgs.runCommand "check-scribe" {
          buildInputs = [
            pkgs.typst
            quick-maths
            scribe
          ];
        } ''
            mkdir -p $out/packages/preview

            cp -r ${scribe}/lib/typst-packages/* $out/packages/preview/
            cp -r ${quick-maths}/lib/typst-packages/* $out/packages/preview/

            cd $out

            cp ${./tests/scribe.typ} test.typ
          
            # 3) compile the Typst file, using our package path
            typst compile test.typ test.pdf \
              --package-cache-path $out/packages
          '';
      }
    );
}
