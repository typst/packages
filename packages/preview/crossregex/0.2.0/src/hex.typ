#import "layout.typ": *
#import "process.typ": *

#let r3 = calc.sqrt(3)

#let crossregex-hex(
  size,
  alphabet: regex("[A-Z]"),
  constraints: (),
  answer: none,
  show-whole: true,
  show-views: true,
  cell: auto,
  cell-config: (:),
  deco-config: (:),
  progress-creator: auto,
  page-margin: 0.5em,
) = {
  if cell == auto {
    cell = rotate(30deg, polygon.regular(size: 2em, vertices: 6, stroke: 0.5pt), origin: center)
  }
  let cell-config = (size: 1em) + cell-config

  let s = cell-config.size

  let n1 = size - 1
  let n2 = size * 2 - 1
  let total = 3 * size * (size - 1) + 1

  let (constraints, max-len, answer, filled, a, aa, progress) = process-args(
    rows: n2,
    row-len: i => n2 - calc.abs(i - n1),
    total: 3 * size * (size - 1) + 1,
    constraints: constraints,
    constraint-size: n2 * 3,
    answer: answer,
    alphabet: alphabet,
    rotators: (
      (i, j) => (n2 - 1 - j - calc.max(i - n1, 0), calc.min(calc.min(i + n1, n2 - 1) - j, i)),
      ((i, j) => (calc.max(n1 - i, 0) + j, calc.min(n2 - 1 - calc.max(i - n1, 0) - j, n2 - i - 1))),
    ),
    progress-creator: progress-creator,
  )

  let center = (x: (n1 + 0.5) * r3 * s, y: (n1 * 1.5 + 1) * s)
  let ext = max-len * 0.5em + 1em // extension by constrains

  let (puzzle-whole, puzzle-view) = build-layout(
    angle: 120deg,
    rows: n2,
    row-len: i => n2 - calc.abs(i - n1),
    cell: cell,
    cell-size: s,
    cell-config: cell-config,
    alphabet: alphabet,
    cell-pos: (i, j) => ((j + calc.abs(i - n1) * 0.5 + 0.5) * r3 * s, (i * 1.5 + 1.0) * s),
    char-box-size: (r3 * s, 1.5 * s),
    deco-pos: i => (center.x + -calc.abs(i - n1) * 0.5 * r3 * s, (i - n1) * 1.5 * s),
    deco-config: deco-config,
    center: center,
    num-views: 3,
    view-size: (center.x * 2 + ext, center.y * 2),
    whole-size: (center.x * 2 + ext * 1.5, center.y * 2 + ext * r3),
    whole-grid-offset: (ext * 0.5, ext * r3 / 2),
  )

  doc-layout(
    whole-maker: if show-whole {
      () => puzzle-whole(constraints, aa)
    },
    view-maker: if show-views {
      k => puzzle-view(constraints.at(k), aa.at(k))
    },
    num-views: 3,
    progress: progress,
    margin: page-margin,
  )
}
