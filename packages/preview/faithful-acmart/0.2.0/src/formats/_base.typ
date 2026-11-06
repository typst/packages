// Shared format defaults and font-size-dependent layout calculations.

// Convert TeX points (1/72.27 inch) to Typst points (1/72 inch).
#let tp = 72.0 / 72.27 * 1pt

// amsart.cls, \@typesizes: each base size selects a clamped window of this ladder.
#let _ladder-size = (5, 6, 7, 8, 9, 10, 10.95, 12, 14.4, 17.28, 20.74, 24.88)
#let _ladder-bls = (6, 7, 8, 10, 11, 12, 13, 14, 17, 20, 24, 30)
#let _step-offset = (
  scriptsize: -3, footnotesize: -2, small: -1, normalsize: 0,
  large: 1, Large: 2, LARGE: 3, huge: 4, Huge: 5,
)

#let size-ladder(
  font-size,
  format: "",
  baseline-stretch: 1,
) = {
  let allowed = (8pt, 9pt, 10pt, 11pt, 12pt)
  assert(
    type(font-size) == length and font-size in allowed,
    message: "faithful-acmart: option `font-size` must be a length, one of "
      + allowed.map(repr).join("/")
      + (if format != "" { " for the " + format + " format" } else { "" })
      + " (got " + repr(font-size) + ").",
  )
  let base = int(calc.round(font-size / 1pt))
  let ni = base - 5
  let pick(arr, step) = arr.at(calc.clamp(ni + _step-offset.at(step), 0, _ladder-size.len() - 1))
  let size = (:)
  let bls = (:)
  for step in _step-offset.keys() {
    size.insert(step, pick(_ladder-size, step) * tp)
    bls.insert(step, baseline-stretch * pick(_ladder-bls, step) * tp)
  }
  // amsart.cls, \@adjustvertspacing.
  let bigskip = 0.7 * bls.normalsize
  (
    size: size,
    bls: bls,
    font-size: size.normalsize,
    baselineskip: bls.normalsize,
    // The review ruler uses the baseline interval before manuscript line stretching.
    baselineskip-unstretched: bls.normalsize / baseline-stretch,
    bigskip: bigskip,
    medskip: bigskip / 2,
    smallskip: bigskip / 4,
  )
}

#let generic-sec-fonts = (
  section:       (family: "sans", weight: "bold", style: "normal", size: "normalsize"),
  subsection:    (family: "sans", weight: "bold", style: "normal", size: "normalsize"),
  subsubsection: (family: "sans", weight: "regular", style: "italic", size: "normalsize"),
  paragraph:     (family: "body", weight: "regular", style: "italic", size: "normalsize"),
)

// geometry's heightrounded rounds text height to the baseline grid.
// The per-size tables are measurements from the bundled class.
#let bottom-margin(font-size, paper-h, top, th-by-size) = {
  let key = str(int(calc.round(font-size / 1pt)))
  (paper-h - top - th-by-size.at(key)) * tp
}

#let numbering-for-depth(depth) = if depth <= 0 { none } else { ("1", "1.1", "1.1.1").at(calc.min(depth, 3) - 1) }

#let make-format(
  name: none,
  kind: "journal",
  ladder: none,
  paper: none,
  margin: none,
  foot-skip: 24 * tp,
  head-offset: 0pt,
  marginpar: none,
  columns: 1,
  columnsep: 10 * tp,
  parindent: 10 * tp,
  title-style: "journal-left",
  title-font: (family: "sans", weight: "bold", size: "LARGE"),
  subtitle-font: (family: "sans", weight: "regular", size: "normalsize"),
  author-font: (family: "sans", weight: "regular", size: "Large"),
  affil-font: (family: "serif", weight: "regular", size: "normalsize"),
  journal: true, // \if@ACM@journal is the static format family flag.
  sans-default: false,
  urlstyle-sans: false,
  secnumdepth: 3,
  title-width-reduction: 0pt,
  sec-fonts: generic-sec-fonts,
  thm: (
    plain-head: "smallcaps", def-head: "italic", indent: auto,
    note-inherits-head: true, proof-head: "smallcaps", proof-indent: auto,
  ),
) = {
  let l = ladder
  (
    name: name,
    kind: kind,
    columns: columns,
    columnsep: columnsep,
    paper: paper,
    margin: margin,
    head: (sep: 14 * tp, offset: head-offset),
    marginpar: marginpar,
    foot: (skip: foot-skip),
    font-size: l.font-size,
    baselineskip: l.baselineskip,
    baselineskip-unstretched: l.at("baselineskip-unstretched"),
    size: l.size,
    bls: l.bls,
    smallskip: l.smallskip, medskip: l.medskip, bigskip: l.bigskip,
    intextsep: 12 * tp, abovecaptionskip: 12 * tp,
    footnote-rule-short: 4 * 12 * tp,
    footnote-rule-kern-above: 3 * tp, footnote-rule-kern-below: 2.6 * tp,
    footins-skip: 7 * tp,
    parindent: parindent,
    parskip: 0pt,
    runin-sep: 3.5 * tp,
    badge-width: 3 * 12 * tp,
    heading-numbering: numbering-for-depth(secnumdepth),
    secnumdepth: secnumdepth,
    title-style: title-style,
    title-font: title-font,
    subtitle-font: subtitle-font,
    author-font: author-font,
    affil-font: affil-font,
    journal: journal,
    sans-default: sans-default,
    urlstyle-sans: urlstyle-sans,
    title-width-reduction: title-width-reduction,
    sec-fonts: sec-fonts,
    thm: thm,
    fonts: (
      serif: "Libertinus Serif",
      sans: "Libertinus Sans",
      mono: "Inconsolatazi4",
      math: "Libertinus Math",
      body: if sans-default { "Libertinus Sans" } else { "Libertinus Serif" },
    ),
  )
}
