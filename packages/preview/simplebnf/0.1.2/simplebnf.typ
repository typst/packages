#let bnf(
  ..body,
) = {
  let content = body.pos().intersperse((none,) * 5 * 2).flatten()

  grid(
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
      left + horizon,
    ),
    inset: 0.28em,
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
  ..vars,
  annot,
) = (
  (
    box(vars.at(0)),
    ..for v in vars.pos().slice(1) {
      (box($|$ + h(0.4em) + v),)
    },
  )
    .intersperse(h(0.4em))
    .join(),
  annot,
)
