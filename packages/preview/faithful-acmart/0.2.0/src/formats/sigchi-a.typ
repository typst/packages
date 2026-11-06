// Layout and typography for legacy SIGCHI extended abstracts.

#import "_base.typ": tp, size-ladder, make-format

#let sigchia(font-size: 10pt) = make-format(
  name: "sigchi-a",
  kind: "proceedings",
  ladder: size-ladder(font-size, format: "sigchi-a"),
  paper: (width: 11in, height: 8.5in),
  margin: (left: 314 * tp, right: 72 * tp, top: 99 * tp, bottom: 84 * tp),
  foot-skip: 12 * tp,
  head-offset: (72 + 170) * tp,
  marginpar: (width: 170 * tp, sep: 72 * tp),
  columnsep: 20 * tp, // Applies to explicit columns(); the body is one column.
  sans-default: true,
  urlstyle-sans: true,
  secnumdepth: 0,
  title-style: "sigchi-rule",
  journal: false,
  title-font: (family: "body", weight: "bold", size: "Huge"),
  subtitle-font: (family: "body", weight: "regular", size: "normalsize"),
  author-font: (family: "sans", weight: "bold", size: "normalsize"),
  affil-font: (family: "sans", weight: "regular", size: "normalsize"),
)
