#let any(..values) = {
  assert.eq(values.named(), (:))
  assert.ne(values.pos(), ())
  metadata(values.pos())
}

#let sel(target, debug: false, scope: (:)) = {
  assert.eq(type(target), selector)
  let expr = repr(target)

  let matches = expr
    .matches(regex(`metadata\(value: \((.*?)\)\)`.text))
    .map(
      m => (
        any: m.text,
        // `trim` is necessary for single-element `any` calls.
        values: m.captures.first().trim(",", at: end).split(", "),
      ),
    )

  // Replace each `any` by any of its possible `values`
  let expanded = matches.fold(
    (expr,),
    (expanded, (any, values)) => values
      .map(
        v => expanded.map(e => e.replace(any, v, count: 1)),
      )
      .flatten(),
  )

  if debug {
    expanded
  } else {
    selector.or(..expanded.map(
      // `repr(table.cell.where(…))` is `cell.where(…)`,
      eval.with(scope: (cell: table.cell) + scope),
    ))
  }
}
