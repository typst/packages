#import "@preview/fletcher:0.5.8": node, shapes

// Node primitives and node-like decorations.
#let _as-offset(x, y) = if type(y) == array {
  y
} else {
  (x, y)
}

#let rnode(
  sym,
  label,
  shape: rect,
  height: 2em,
  corner-radius: 4pt,
  ..options,
) = node(
  sym,
  label,
  shape: shape,
  corner-radius: corner-radius,
  height: height,
  ..options,
)

#let onode(
  sym,
  label,
  shape: circle,
  height: 1em,
  radius: 10pt,
  ..options,
) = node(
  sym,
  label,
  shape: shape,
  radius: radius,
  height: height,
  ..options,
)

#let gain-node(
  sym,
  label,
  dir: left,
  width: 4em,
  height: 4em,
  fit: 0.8,
  ..options,
) = node(
  sym,
  label,
  shape: shapes.triangle.with(dir: dir, fit: fit),
  width: width,
  height: height,
  ..options,
)

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

#let label(sym, body, stroke: none, ..options) = node(
  sym,
  body,
  stroke: stroke,
  ..options,
)

#let signed-node(
  sym,
  signs: (),
  node-maker: onode,
  label-maker: label,
  ..node-options,
) = {
  node-maker(sym, none, ..node-options)
  for sign in signs {
    if sign.body != none {
      label-maker(
        (sym.at(0) + sign.offset.at(0), sym.at(1) + sign.offset.at(1)),
        sign.body,
      )
    }
  }
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
) = node(
  enclose: enclose,
  shape: rect,
  stroke: stroke,
  fill: fill,
  inset: inset,
  corner-radius: corner-radius,
  ..options,
)
