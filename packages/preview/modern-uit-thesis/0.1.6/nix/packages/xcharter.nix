{ pkgs }:

pkgs.stdenv.mkDerivation {
  pname = "XCharter";
  version = "1.26";

  src = pkgs.fetchzip {
    url = "https://mirrors.ctan.org/fonts/xcharter.zip";
    hash = "sha256-2PfPmG15Q+woBzZ7BSC/6aq566/4PM40w1766+miRgg=";
  };

  installPhase = ''
    runHook preInstall
    install -Dm644 -t $out/share/fonts/opentype/ opentype/*.otf
    runHook postInstall
  '';
}
