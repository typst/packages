#import "core.typ": *

#let rnode(
  sym,
  label,
  shape: rect,
  width: auto,
  height: 2em,
  corner-radius: 4pt,
  fill: none,
  stroke: auto,
  ..options,
) = draw.get-ctx(ctx => {
  let _ = (shape, options)
  let height = _resolve(ctx, height)
  let width = if width == auto {
    let padding = _resolve(ctx, 0.8em)
    calc.max(_measure(ctx, label).at(0) + padding, height * 1.6)
  } else {
    _resolve(ctx, width)
  }
  let stroke = if stroke == auto { _defaults(ctx).node-stroke } else { stroke }
  let (a, b) = _rect-corners(sym, width, height)
  _register-shape(
    sym,
    (kind: "rect", center: sym, width: width, height: height),
    draw.rect(a, b, radius: corner-radius, fill: fill, stroke: stroke),
    label: label,
  )
})

#let onode(
  sym,
  label,
  shape: circle,
  height: 1em,
  radius: 10pt,
  fill: none,
  stroke: auto,
  ..options,
) = draw.get-ctx(ctx => {
  let _ = (shape, height, options)
  let padding = _resolve(ctx, 0.35em)
  let size = _measure(ctx, label)
  let rx = calc.max(_resolve(ctx, radius), size.at(0) / 2 + padding)
  let ry = calc.max(_resolve(ctx, radius), size.at(1) / 2 + padding)
  let stroke = if stroke == auto { _defaults(ctx).node-stroke } else { stroke }
  _register-shape(
    sym,
    (kind: "circle", center: sym, rx: rx, ry: ry),
    draw.circle(sym, radius: (rx, ry), fill: fill, stroke: stroke),
    label: label,
  )
})

#let gain-node(
  sym,
  label,
  dir: left,
  width: 4em,
  height: 4em,
  fit: 0.8,
  fill: none,
  stroke: auto,
  ..options,
) = draw.get-ctx(ctx => {
  let _ = (fit, options)
  let stroke = if stroke == auto { _defaults(ctx).node-stroke } else { stroke }
  let points = _triangle-points(
    sym,
    _resolve(ctx, width),
    _resolve(ctx, height),
    dir,
  )
  _register-shape(
    sym,
    (kind: "polygon", center: sym, points: points),
    draw.line(..points, close: true, fill: fill, stroke: stroke),
    label: label,
  )
})

#let formula-node(
  sym,
  body,
  width: 8em,
  height: 3em,
  ..options,
) = rnode(
  sym,
  body,
  width: width,
  height: height,
  ..options,
)

#let label(sym, body, stroke: none, fill: none, inset: 0pt, ..options) = {
  let _ = options
  if stroke == none and fill == none {
    draw.content(sym, body)
  } else {
    draw.content(sym, box(inset: inset, stroke: stroke, fill: fill, body))
  }
}

#let signed-node(
  sym,
  signs: (),
  node-maker: onode,
  label-maker: label,
  ..node-options,
) = {
  let body = node-maker(sym, none, ..node-options)
  for sign in signs {
    if sign.body != none {
      body += label-maker(_offset-point(sym, sign.offset), sign.body)
    }
  }
  draw.scope(body)
}

#let reference(
  sym,
  x-sign: "+",
  y-sign: "-",
  x-offset: -.3,
  y-offset: .3,
  loss: none,
  loss-offset: -.5,
  ..options,
) = signed-node(
  sym,
  signs: (
    (body: loss, offset: _as-offset(0, loss-offset)),
    (body: x-sign, offset: (x-offset, 0)),
    (body: y-sign, offset: (0, y-offset)),
  ),
  ..options,
)

#let reference3(
  sym,
  x: "+",
  top: "+",
  bottom: "+",
  x-offset: -0.25,
  top-offset: -0.25,
  bottom-offset: 0.25,
  radius: 1.35em,
  node-maker: onode,
  label-maker: label,
  ..node-options,
) = signed-node(
  sym,
  signs: (
    (body: x, offset: (x-offset, 0)),
    (body: top, offset: (0, top-offset)),
    (body: bottom, offset: (0, bottom-offset)),
  ),
  radius: radius,
  node-maker: node-maker,
  label-maker: label-maker,
  ..node-options,
)

#let dashed-box(
  enclose,
  stroke: (thickness: 0.5pt, dash: "dashed"),
  inset: 1.5em,
  fill: none,
  corner-radius: 4pt,
  ..options,
) = draw.rect-around(
  enclose,
  stroke: stroke,
  padding: inset,
  fill: fill,
  radius: corner-radius,
  ..options,
)
