#let distr(s, w: auto) = {
  block(
    width: w,
    stack(
      dir: ltr,
      ..s.clusters().map(x => [#x]).intersperse(1fr),
    ),
  )
}

