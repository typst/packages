#let bnf(
  ..body,
) = {
  let content = body.pos().flatten()

  table(
    columns: (
      auto,
      auto,
      auto,
      auto,
      auto,
    ),
    align: (
      right,
      center,
      center,
      left,
      left,
    ),
    inset: 2.7pt,
    stroke: none,
    ..content,
  )
}

#let Prod(
  lhs,
  annot: none,
  delim: $::=$,
  ..rhs,
) = {
  let pad = (
    none,
    none,
    $|$,
  )
  let rhses = rhs.pos().flatten().chunks(2).intersperse(pad)
  (
    annot,
    lhs,
    delim,
    rhses,
  )
}

#let Or(
  var,
  annot,
) = (
  var,
  annot,
)
