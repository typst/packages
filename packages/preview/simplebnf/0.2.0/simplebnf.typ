#let bnf(
  inset: 0.28em,
  ..body,
) = {
  let content = body.pos().intersperse((none,) * 5 * 2).flatten()

  // This 'set' calls defines a default value for all inset
  // dimensions, so that callers can use `inset: (y: 1em,)` and have
  // the `x` dimension implicitly set at 0.28em as intended.
  set grid(inset: 0.28em)

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
    inset: inset,
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
