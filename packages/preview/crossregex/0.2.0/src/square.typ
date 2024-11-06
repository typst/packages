#import "layout.typ": *
#import "process.typ": *

#let crossregex-square(
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
    cell = polygon.regular(size: calc.sqrt(2) * 1em, vertices: 4, stroke: 0.5pt)
  }
  let cell-config = (size: 1em) + cell-config

  let s = cell-config.size

  let n = size
  let total = n * n

  let (constraints, max-len, answer, a, aa, progress) = process-args(
    rows: n,
    row-len: i => n,
    total: n * n,
    constraints: constraints,
    constraint-size: n * 2,
    answer: answer,
    alphabet: alphabet,
    rotators: ((i, j) => (j, n - i - 1),),
    progress-creator: progress-creator,
  )

  let center = (x: n * 0.5 * s, y: n * 0.5 * s)
  let ext = max-len * 0.5em + 1em // extension by constrains

  let (puzzle-whole, puzzle-view) = build-layout(
    angle: 90deg,
    rows: n,
    row-len: _ => n,
    cell: cell,
    cell-size: s,
    cell-config: cell-config,
    alphabet: alphabet,
    cell-pos: (i, j) => ((j + 0.5) * s, (i + 0.5) * s),
    char-box-size: (s, s),
    deco-pos: i => (center.x, (i - n * 0.5 + 0.5) * s),
    deco-config: deco-config,
    center: center,
    num-views: 2,
    view-size: (n * s + ext, n * s),
    whole-size: (center.x * 2 + ext, center.y * 2 + ext),
  )

  doc-layout(
    whole-maker: if show-whole {
      () => puzzle-whole(constraints, aa)
    },
    view-maker: if show-views {
      k => puzzle-view(constraints.at(k), aa.at(k))
    },
    num-views: 2,
    progress: progress,
    margin: page-margin,
  )
}
