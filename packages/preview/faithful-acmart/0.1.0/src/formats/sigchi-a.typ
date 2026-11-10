// sigchi-a format — landscape SIGCHI extended abstracts.
//
// Landscape 11x8.5, single wide column with a large (314pt) left margin for
// marginal notes, sans-serif document default (acmart.dtx:4073), 10pt. The title
// is @mktitle@iv (a 5pc-leftskip ragged title under a leading 2pt rule,
// acmart.dtx:7039), authors use the @mkauthors@iv grid (acmart.dtx:7518), and
// sections are unnumbered (secnumdepth 0). Geometry probed from the class.
//
// The geometry, sans default, rule title (5pc leftskip), @iv author grid (bold
// mixed-case name + email + affiliation, 2 per row), one-sided running head, and
// the "Legacy document" watermark (drawn in lib.typ) are reproduced — text matches
// LaTeX exactly. The remaining approximation: footnotes are NOT moved into the
// margin (acmart.dtx:3533 \marginpar).
#import "_base.typ": tp, size-ladder, make-format

#let sigchia(font-size: 10pt) = make-format(
  name: "sigchi-a",
  kind: "proceedings",
  ladder: size-ladder(font-size, format: "sigchi-a"),
  paper: (width: 11in, height: 8.5in),
  // one-sided with a wide left margin (marginpar 170pt sits inside the 314pt
  // left margin via \reversemarginpar).
  margin: (left: 314 * tp, right: 72 * tp, top: 99 * tp, bottom: 84 * tp), // head top 58
  foot-skip: 24 * tp,
  sans-default: true,
  urlstyle-sans: true,
  secnumdepth: 0,
  title-style: "sigchi-rule",
  bibstrip: false,
  // \@titlefont \Huge\bfseries — no \sffamily, so it inherits the document default
  // family, which is sans here (acmart.dtx:6930); `body` resolves to that.
  title-font: (family: "body", weight: "bold", size: "Huge"),
  subtitle-font: (family: "body", weight: "regular", size: "normalsize"),
  // \@authorfont \bfseries ; \@affiliationfont \mdseries (sans, the default family)
  author-font: (family: "sans", weight: "bold", size: "normalsize"),
  affil-font: (family: "sans", weight: "regular", size: "normalsize"),
)
