// 图文混排(左文右图)
#let text-figure(
  figure: none,
  figure-x: 0pt,
  figure-y: 0pt,
  top: 0pt,
  bottom: 0pt,
  gap: 0pt,
  style: "tf",
  text,
) = context {
  assert(style == "tf" or style == "ft", message: "style must be 'tf' or 'ft'")
  let _columns = (1fr, measure(figure).width)
  let _gap = -figure-x + gap
  let body = (text, place(dy: figure-y, dx: figure-x, horizon, figure))
  if style == "ft" {
    body = body.rev()
    _columns = _columns.rev()
    _gap = figure-x + gap
  }
  let dpar = par.leading - par.spacing
  grid(
    columns: _columns,
    align: horizon,
    inset: (
      top: top + dpar,
      bottom: bottom + dpar,
    ),
    gutter: _gap,
    ..body,
  )
}
