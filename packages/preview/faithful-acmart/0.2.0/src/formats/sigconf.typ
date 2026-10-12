// Layout and typography for ACM conference proceedings.

#import "_base.typ": tp, size-ladder, make-format, bottom-margin, generic-sec-fonts

#let sigconf(font-size: 9pt) = make-format(
  name: "sigconf",
  kind: "proceedings",
  ladder: size-ladder(font-size, format: "sigconf"),
  paper: (width: 8.5in, height: 11in),
  margin: (
    inside: 54 * tp,
    outside: 54 * tp,
    top: 84 * tp,
    bottom: bottom-margin(font-size, 794.97, 84, ("8": 630, "9": 626, "10": 622, "11": 621, "12": 626)),
  ),
  foot-skip: 12 * tp,
  columns: 2,
  columnsep: 24 * tp,
  title-style: "conf-center",
  journal: false,
  title-font: (family: "sans", weight: "bold", size: "Huge"),
  subtitle-font: (family: "sans", weight: "regular", size: "LARGE"),
  author-font: (family: "serif", weight: "regular", size: "LARGE"),
  affil-font: (family: "serif", weight: "regular", size: "large"),
  sec-fonts: generic-sec-fonts + (
    section:    (family: "serif", weight: "bold", style: "normal", size: "Large"),
    subsection: (family: "serif", weight: "bold", style: "normal", size: "Large"),
  ),
)
