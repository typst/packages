{
  pkgs,
}:
pkgs.buildTypstPackage (finalAttrs: rec {
  name = "glossarium";
  pname = "glossarium";
  version = "0.5.6";
  src = pkgs.fetchzip {
    url = "https://packages.typst.org/preview/${pname}-${version}.tar.gz";
    hash = "sha256-PSJistNVYaEt1VjLxTzieSrOCNKkdbl8x5JWrF/6qfM=";
    stripRoot = false;
  };
})
