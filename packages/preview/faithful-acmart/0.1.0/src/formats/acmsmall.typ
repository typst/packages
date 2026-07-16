// acmsmall format — single-column journal layout.
//
// All measurements are taken from the real acmart.cls (format=acmsmall) via a
// layout probe (tools/probe.tex; run `tools/test.py probe`). The shared font-size ladder,
// TeX->PS point conversion, and the dict constructor live in `_base.typ`.
#import "_base.typ": tp, size-ladder, make-format

// Build the acmsmall format dict for a given base font size (one of
// "8pt".."12pt"; acmsmall's own default is 10pt — acmart.dtx:3068). Geometry,
// margins, parindent, and the float/list/footnote/badge constants do NOT depend
// on the font size (acmart.dtx:3750, "the present margins do not depend on the
// font size option"); only the typography (font-size, baselineskip, the
// size/bls step tables, and the amsart \small/\med/\bigskip) scales.
//
// Ground-truth geometry (TeX points) from the probe — font-size-independent:
//   paper 6.75in x 10in ; textwidth 395.8225 ; textheight 574
//   inner/outer 46 ; top(to head) 58 ; head 13 ; headsep 14 -> body top 85
//   footskip 24 ; parindent 10 ; parskip 0
#let acmsmall(font-size: 10pt) = make-format(
  name: "acmsmall",
  ladder: size-ladder(font-size, format: "acmsmall"),
  paper: (width: 6.75in, height: 10in),
  margin: (
    inside: 46 * tp,
    outside: 46 * tp,
    top: 85 * tp,                     // 58 (to head top) + 13 (head) + 14 (headsep)
    bottom: (722.7 - 85 - 574) * tp,  // = 63.7tp; paperheight - bodytop - textheight
  ),
  foot-skip: 24 * tp,
  // \@authorfont \large\sffamily ; \@affiliationfont \small\normalfont
  // (acmart.dtx:7209) — acmsmall is a step smaller than acmart's generic default.
  author-font: (family: "sans", weight: "regular", size: "large"),
  affil-font: (family: "serif", weight: "regular", size: "small"),
  // single-column journal: left title, author list, journal bibstrip, generic
  // section fonts (acmart.dtx:6877/7337/2982/8415) — all make-format defaults.
)
