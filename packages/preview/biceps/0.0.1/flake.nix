{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
    in
    {
      devShell.x86_64-linux =
        with pkgs;
        mkShell {
          buildInputs = [
            typst
            typstyle
            zathura
          ];
          shellHook = ''
            unset SOURCE_DATE_EPOCH # Typst will think it is 1980-01-01 otherwise
          '';
        };
    };
}
