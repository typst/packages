#import "raw.typ": *
#import "style.typ": hatch

// -----------------------------------------------------------------------------
// Default
// -----------------------------------------------------------------------------

/// The default pre-theme.
#let pre-default = (
  code: (
    line-spacing: auto,
    theme: auto,
    color: auto,
    fill: none,
    indentation: gray,
    indented-line-return: true,
    indent-size: auto,
  ),
  numbers: (
    start: auto,
    end: none,
    format: auto,
    color: auto,
    fill: auto,
    gutter: auto,
    sep: none,
    align: top + right,
  ),
  general: (
    coloring-follow-numbers: true,
    markers-over-numbers: false,
    line-reference: n => ", line " + str(n) + ",",
    default-stroke-thickness: .5pt,
  ),
  header: (
    content: none,
    color: auto,
    fill: none,
    repeat: false,
    sep: auto,
    inset: 5pt,
    align: left + horizon,
    code-aligned: false,
  ),
  footer: (
    content: none,
    color: auto,
    fill: none,
    repeat: false,
    sep: auto,
    inset: 5pt,
    align: left + horizon,
    code-aligned: false,
  ),
  frame: (
    breakable: true,
    sharp-page-break: true,
    width: auto,
    fill: none,
    stroke: none,
    radius: 1mm,
    inset: (x: 3pt),
  ),
  lang-tag: (
    visible: true,
    name: auto,
    icon: none,
    placement: "code",
    spacing: 5pt,
    color: auto,
    fill: black.transparentize(90%),
    radius: 2pt,
    stroke: auto,
  ),
  highlight: (
    fill: yellow.transparentize(70%),
    stroke: yellow,
    radius: 3pt,
    code-style: it => it,
    sticky: auto,
    expand: auto,
  ),
  comment: (
    style: text.with(style: "italic"),
    indent: false,
    fill: luma(245),
    separate: false,
    marker: none,
    marker-fill: auto,
    marker-placement: "numbers",
  ),
  jump: (
    comment: none,
    style: auto,
    indent: auto,
    fill: auto,
    separate: auto,
    marker: auto,
    marker-fill: auto,
    marker-placement: auto,
  ),
  diff: (
    general: (
      columns: (auto, auto),
      column-gutter: 0pt,
      sep: gray,
      blank-fill: hatch(luma(200)),
      line-reference: (n, version) => ", " + version + " line " + str(n) + ",",
    ),
    old: (
      diff-marker: text(red.darken(20%))[-],
      fill: red.lighten(75%),
      numbers-color: auto,
      numbers-fill: rgb("#FF8B85"),
    ),
    new: (
      diff-marker: text(olive)[+],
      fill: rgb("#32C04C").lighten(75%),
      numbers-color: auto,
      numbers-fill: rgb("#7CCBA7"),
    ),
    diff-marker: (
      visible: true,
      unchanged: [],
      gutter: 3pt,
    ),
    comment: (span: false),
    jump: (span: auto),
  ),
)

// -----------------------------------------------------------------------------
// Dark
// -----------------------------------------------------------------------------

/// The pre-theme for the dark theme.
#let pre-dark = (
  code: (
    theme: typst-dark,
    color: luma(230),
    fill: luma(50),
    indentation: luma(100),
  ),
  numbers: (fill: none, sep: none),
  frame: (fill: luma(25)),
  lang-tag: (fill: white.transparentize(75%), stroke: none),
  highlight: (fill: purple.transparentize(60%), stroke: purple.lighten(20%)),
  comment: (fill: luma(80)),
  diff: (
    general: (sep: none),
    old: (
      diff-marker: text(red)[-],
      fill: red.darken(60%),
      numbers-fill: rgb("#B80900"),
    ),
    new: (
      diff-marker: text(olive.lighten(30%))[+],
      fill: olive.darken(45%),
      numbers-fill: rgb("#348360"),
    ),
  ),
)

// -----------------------------------------------------------------------------
// Note
// -----------------------------------------------------------------------------

/// The pre-theme for the note theme.
#let pre-note = (
  numbers: (align: top + left, sep: black),
  frame: (fill: luma(250), stroke: black, inset: (x: 3pt, y: 2.5pt)),
  lang-tag: (fill: auto, placement: "top-right"),
  highlight: (stroke: none, radius: 0pt),
  comment: (style: it => it, separate: true),
  jump: (separate: false),
  diff: (general: (blank-fill: hatch(black), sep: black)),
)

// -----------------------------------------------------------------------------
// Window
// -----------------------------------------------------------------------------

/// The pre-theme for the window theme.
#let pre-window = (
  code: (indentation: silver),
  frame: (
    fill: white,
    stroke: 1pt + luma(240),
    radius: 5pt,
    inset: (x: 3pt, y: 2pt),
  ),
  header: (fill: luma(240), sep: none),
  footer: (fill: luma(240), sep: none),
  lang-tag: (placement: "header"),
  highlight: (fill: blue.transparentize(80%), stroke: none, expand: left),
  comment: (fill: luma(245)),
  diff: (general: (sep: 1pt + luma(240))),
)

// -----------------------------------------------------------------------------
// Pseudo
// -----------------------------------------------------------------------------

/// The default pre-theme for `uraw-pseudo`.
#let pseudo-pre-default = (
  code: (
    style: none,
    line-spacing: auto,
    color: auto,
    fill: none,
    indentation: none,
    indent-size: 15pt,
  ),
  numbers: (
    start: 1,
    end: none,
    format: "1:",
    color: auto,
    fill: auto,
    gutter: auto,
    sep: none,
    align: top + right,
  ),
  general: (
    coloring-follow-numbers: true,
    algorithm-figure: true,
    line-reference: n => ", line " + str(n) + ",",
    default-stroke-thickness: .5pt,
  ),
  header: (
    content: none,
    color: auto,
    fill: none,
    repeat: false,
    sep: auto,
    inset: (y: .4em),
    align: left + horizon,
    code-aligned: false,
  ),
  footer: (
    content: none,
    color: auto,
    fill: none,
    repeat: false,
    sep: auto,
    inset: (y: .4em),
    align: left + horizon,
    code-aligned: false,
  ),
  frame: (
    breakable: true,
    sharp-page-break: true,
    width: auto,
    fill: none,
    radius: (:),
    stroke: (top: 1pt + black, bottom: 1pt + black),
    inset: (x: .25em),
  ),
  comment: (
    style: text.with(style: "italic"),
    indent: true,
    fill: luma(245),
    separate: false,
    marker: none,
    marker-fill: auto,
  ),
)
