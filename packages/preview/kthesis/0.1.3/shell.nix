{
  pkgs ? (import <nixpkgs> { }),
  unstable ? (import <unstable> { }),
}:
pkgs.mkShellNoCC {
  buildInputs = with pkgs; [
    unstable.typst
    unstable.typstyle
    poppler_utils # for pdfinfo, to see metadata
  ];
}
