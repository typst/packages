// sigconf format — two-column proceedings layout (most ACM conferences).
//
// 8.5x11, two columns (colsep 2pc), 9pt default (acmart.dtx:3074). Centered
// conference title (@mktitle@iii, \Huge\sffamily\bfseries) over a centered author
// grid (@mkauthors@iii), no journal bibstrip — the conference info + permission +
// ISBN sit in a first-column copyright block. Section headings are \bfseries\Large
// (serif bold, acmart.dtx:8430). Geometry probed from the bundled class.
#import "_base.typ": tp, size-ladder, make-format, generic-sec-fonts

#let sigconf(font-size: 9pt) = make-format(
  name: "sigconf",
  kind: "proceedings",
  ladder: size-ladder(font-size, format: "sigconf"),
  paper: (width: 8.5in, height: 11in),
  margin: (
    inside: 54 * tp,
    outside: 54 * tp,
    top: 84 * tp,          // geometry top=57 + 13 + 14
    bottom: 84.97 * tp,
  ),
  foot-skip: 12 * tp,
  columns: 2,
  columnsep: 24 * tp,      // 2pc
  // conference top matter (acmart.dtx:6884/7167): centered title + author grid,
  // first-column copyright block (conf-info-line), no journal footer (bibstrip
  // false). acmart \flushbottom-justifies these pages; Typst can't (ragged-bottom).
  title-style: "conf-center",
  bibstrip: false,
  // \@titlefont \Huge\sffamily\bfseries ; \@subtitlefont \LARGE\mdseries (sans)
  title-font: (family: "sans", weight: "bold", size: "Huge"),
  subtitle-font: (family: "sans", weight: "regular", size: "LARGE"),
  // \@authorfont \LARGE (serif) ; \@affiliationfont \large (serif) — acmart.dtx:7216
  author-font: (family: "serif", weight: "regular", size: "LARGE"),
  affil-font: (family: "serif", weight: "regular", size: "large"),
  // \@secfont/\@subsecfont = \bfseries\Large (serif bold); subsubsection/paragraph
  // stay generic (sans italic / serif italic) (acmart.dtx:8430).
  sec-fonts: generic-sec-fonts + (
    section:    (family: "serif", weight: "bold", style: "normal", size: "Large"),
    subsection: (family: "serif", weight: "bold", style: "normal", size: "Large"),
  ),
)
