// sigplan format — two-column proceedings (SIGPLAN conferences).
//
// Two columns, 10pt default (acmart.dtx:3078), 1in/0.75in margins (probed; note
// includeheadfoot=false). Distinct from sigconf: the title is \Huge\bfseries with
// NO sans (serif bold, acmart.dtx:6926), the sections are serif bold
// (\bfseries\Large section, \bfseries subsection, \bfseries\itshape paragraph;
// acmart.dtx:8435), and URLs are set in sans (\urlstyle{sf}, acmart.dtx:3623).
#import "_base.typ": tp, size-ladder, make-format, generic-sec-fonts

#let sigplan(font-size: 10pt) = make-format(
  name: "sigplan",
  kind: "proceedings",
  ladder: size-ladder(font-size, format: "sigplan"),
  paper: (width: 8.5in, height: 11in),
  margin: (inside: 54.2025 * tp, outside: 54.2025 * tp, top: 72.27 * tp, bottom: 76.7 * tp), // head top 45.27
  foot-skip: 12 * tp,
  columns: 2,
  columnsep: 24 * tp,
  // centered conf title + author grid, first-column copyright block (no journal
  // footer). acmart \flushbottom-justifies these pages; Typst can't (ragged-bottom).
  title-style: "conf-center",
  bibstrip: false,
  urlstyle-sans: true,
  // \@titlefont \Huge\bfseries (serif) ; \@subtitlefont \LARGE\mdseries (serif)
  title-font: (family: "serif", weight: "bold", size: "Huge"),
  subtitle-font: (family: "serif", weight: "regular", size: "LARGE"),
  // \@authorfont \Large\normalfont (serif) ; \@affiliationfont \normalsize (serif)
  author-font: (family: "serif", weight: "regular", size: "Large"),
  affil-font: (family: "serif", weight: "regular", size: "normalsize"),
  // \@secfont \bfseries\Large ; \@subsecfont \bfseries ; \@subsubsecfont \bfseries ;
  // \@parfont \bfseries\itshape (all serif) — acmart.dtx:8435-8440.
  sec-fonts: (
    section:       (family: "serif", weight: "bold", style: "normal", size: "Large"),
    subsection:    (family: "serif", weight: "bold", style: "normal", size: "normalsize"),
    subsubsection: (family: "serif", weight: "bold", style: "normal", size: "normalsize"),
    paragraph:     (family: "serif", weight: "bold", style: "italic", size: "normalsize"),
  ),
)
