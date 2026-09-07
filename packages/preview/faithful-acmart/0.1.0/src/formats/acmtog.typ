// acmtog format — large two-column journal layout (ACM TOG and similar).
//
// Two columns (colsep 24pt), 9pt default (acmart.dtx:3072), but unlike the
// proceedings formats it keeps the JOURNAL top matter: left-aligned @mktitle@i
// title and the author *list* (@mkauthors@i), the contact-info footnote, and the
// ACM journal bibstrip footer (it is journal + tog, acmart.dtx:2986). parindent
// is 9pt (acmart.dtx:3846). Larger title/author/section fonts than acmsmall:
// \Huge\sffamily title, \LARGE\sffamily authors, \sffamily\large sections.
// Geometry probed from the bundled class.
#import "_base.typ": tp, size-ladder, make-format, generic-sec-fonts

#let acmtog(font-size: 9pt) = make-format(
  name: "acmtog",
  ladder: size-ladder(font-size, format: "acmtog"),
  paper: (width: 8.5in, height: 11in),
  margin: (inside: 52 * tp, outside: 52 * tp, top: 79 * tp, bottom: 100.97 * tp), // head top 52
  foot-skip: 24 * tp,
  columns: 2,
  columnsep: 24 * tp,
  parindent: 9 * tp,       // acmart.dtx:3846
  // journal top matter in two columns: left title spanning both columns, author
  // list, contact-info footnote + ACM bibstrip (bibstrip true). acmart
  // \flushbottom-justifies these pages; Typst can't (ragged-bottom).
  title-style: "journal-left",
  // \@titlefont \Huge\sffamily (no bold) ; \@subtitlefont \LARGE (sans)
  title-font: (family: "sans", weight: "regular", size: "Huge"),
  subtitle-font: (family: "sans", weight: "regular", size: "LARGE"),
  // \@authorfont \LARGE\sffamily ; \@affiliationfont \large — no \normalfont, so the
  // affiliation inherits the sans author font (acmart.dtx:7213), unlike acmsmall.
  author-font: (family: "sans", weight: "regular", size: "LARGE"),
  affil-font: (family: "sans", weight: "regular", size: "large"),
  // \@secfont/\@subsecfont = \sffamily\large (regular weight, acmart.dtx:8427)
  sec-fonts: generic-sec-fonts + (
    section:    (family: "sans", weight: "regular", style: "normal", size: "large"),
    subsection: (family: "sans", weight: "regular", style: "normal", size: "large"),
  ),
)
