{
  pkgs ? (import <nixpkgs> { }),
  unstable ? (import <unstable> { }),
}:
pkgs.mkShellNoCC {
  buildInputs = with pkgs; [
    unstable.typst
    unstable.typstyle
    poppler-utils # for pdfinfo, to see metadata
  ];
}
