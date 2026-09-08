// acmlarge format — large single-column journal layout (DLT, DTRAP, HEALTH, …).
//
// 8.5x11, wide margins, 10pt default (acmart.dtx:3070). Same single-column
// journal topmatter as acmsmall, but the section headings are \sffamily\large and
// NOT bold (acmart.dtx:8424) — sans, regular weight, one size step up.
// Geometry probed from the bundled class (`tools/test.py probe`); values in TeX points.
#import "_base.typ": tp, size-ladder, make-format, generic-sec-fonts

#let acmlarge(font-size: 10pt) = make-format(
  name: "acmlarge",
  ladder: size-ladder(font-size, format: "acmlarge"),
  paper: (width: 8.5in, height: 11in),
  margin: (
    inside: 81 * tp,
    outside: 81 * tp,
    top: 105 * tp,         // geometry top=78 (head top) + 13 + 14
    bottom: 139.96999 * tp,
  ),
  foot-skip: 24 * tp,
  // \@secfont/\@subsecfont = \sffamily\large (regular weight, size step up);
  // subsubsection/paragraph stay generic (acmart.dtx:8424).
  sec-fonts: generic-sec-fonts + (
    section:    (family: "sans", weight: "regular", style: "normal", size: "large"),
    subsection: (family: "sans", weight: "regular", style: "normal", size: "large"),
  ),
)
