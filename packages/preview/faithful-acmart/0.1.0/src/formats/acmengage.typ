// acmengage format — two-column ACM EngageCSEdu course materials.
//
// A sigconf variant: two columns, 9pt, centered conference title + author grid.
// Same author/section fonts as sigconf (\@authorfont \LARGE serif; \@secfont
// \bfseries\Large, acmart.dtx:7231/8450). Slightly taller bottom margin (probed).
// The engage copyright line uses the booktitle rather than a conference (handled
// by conf-info-line's booktitle branch). Geometry probed from the class.
#import "_base.typ": tp, size-ladder, make-format, generic-sec-fonts

#let acmengage(font-size: 10pt) = make-format(
  name: "acmengage",
  kind: "proceedings",
  ladder: size-ladder(font-size, format: "acmengage"),
  paper: (width: 8.5in, height: 11in),
  margin: (inside: 54 * tp, outside: 54 * tp, top: 84 * tp, bottom: 88.97 * tp), // head top 57
  foot-skip: 12 * tp,
  columns: 2,
  columnsep: 24 * tp,
  // centered conf title + author grid, first-column copyright block (no journal
  // footer). acmart \flushbottom-justifies these pages; Typst can't (ragged-bottom).
  title-style: "conf-center",
  bibstrip: false,
  title-font: (family: "sans", weight: "bold", size: "Huge"),
  subtitle-font: (family: "sans", weight: "regular", size: "LARGE"),
  author-font: (family: "serif", weight: "regular", size: "LARGE"),
  affil-font: (family: "serif", weight: "regular", size: "large"),
  sec-fonts: generic-sec-fonts + (
    section:    (family: "serif", weight: "bold", style: "normal", size: "Large"),
    subsection: (family: "serif", weight: "bold", style: "normal", size: "Large"),
  ),
)
