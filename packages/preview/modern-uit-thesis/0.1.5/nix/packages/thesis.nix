{
  pkgs,
  xcharter,
  glossarium,
}:
let
  fontPackages = with pkgs; [
    noto-fonts
    open-sans
    jetbrains-mono
    xcharter
  ];
in
pkgs.buildTypstDocument rec {
  name = "modern-uit-thesis";
  src = ./../..;
  file = "template/thesis.typ";
  buildInputs = [ glossarium ];
  typstEnv = (
    p: [
      p.codly_1_3_0
      p.ctheorems_1_1_3
      p.physica_0_9_5
      p.subpar_0_2_2
      # NOTE(mrtz): Update when 0.5.6 is in nixpkgs
      glossarium
    ]
  );
  fonts = fontPackages;
  format = "pdf";

  # TODO(mrtz): Upstream to nixpkgs
  buildPhase = ''
    runHook preBuild
    mkdir -p $out
    typst c ${file} --root ./ -f ${format} $out/thesis.pdf
    runHook postBuild
  '';
}
