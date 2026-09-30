// Layout and typography for ACM Transactions on Graphics.

#import "_base.typ": tp, size-ladder, make-format, bottom-margin, generic-sec-fonts

#let acmtog(font-size: 9pt) = make-format(
  name: "acmtog",
  ladder: size-ladder(font-size, format: "acmtog"),
  paper: (width: 8.5in, height: 11in),
  margin: (inside: 52 * tp, outside: 52 * tp, top: 79 * tp,
    bottom: bottom-margin(font-size, 794.97, 79, ("8": 620, "9": 615, "10": 622, "11": 621, "12": 612))),
  foot-skip: 24 * tp,
  columns: 2,
  columnsep: 24 * tp,
  parindent: 9 * tp,
  title-style: "journal-left",
  title-font: (family: "sans", weight: "regular", size: "Huge"),
  subtitle-font: (family: "sans", weight: "regular", size: "LARGE"),
  // \@affiliationfont inherits the author font family because it omits \normalfont.
  author-font: (family: "sans", weight: "regular", size: "LARGE"),
  affil-font: (family: "sans", weight: "regular", size: "large"),
  sec-fonts: generic-sec-fonts + (
    section:    (family: "sans", weight: "regular", style: "normal", size: "large"),
    subsection: (family: "sans", weight: "regular", style: "normal", size: "large"),
  ),
)
