// The sketch canvas: flatten op arrays, resolve styles, call the engine,
// place the resulting curves in a sized block.
#import "engine.typ": _engine, _pt, render-paths
#import "style.typ": auto-seed, engine-fill-style, engine-stroke-style, resolve-style

#let _flip(op, h) = {
  let fy(p) = (p.at(0), h - p.at(1))
  if op.op == "stroke" { op + (points: op.points.map(fy)) }
  else { op + (boundaries: op.boundaries.map(b => b.map(fy))) }
}

/// Render resolved ops. `offset` shifts all geometry (used by annotate).
#let render-ops(ops, offset: (0, 0)) = {
  for op in ops {
    if type(op) != dictionary or "op" not in op or op.op not in ("stroke", "fill") {
      panic("chalks: sketch elements must be shape ops, got " + repr(op))
    }
    let shift(p) = (p.at(0) + offset.at(0), p.at(1) + offset.at(1))
    let s = resolve-style(op.style)
    if op.op == "stroke" {
      let pts = op.points.map(shift).map(_pt)
      let seed = op.style.at("seed", default: auto-seed(("stroke", pts, op.closed)))
      let req = cbor.encode((
        points: pts, closed: op.closed, style: engine-stroke-style(s), seed: seed,
      ))
      render-paths(cbor(_engine.stroke(req)).paths, s.color, s.opacity)
    } else {
      let bs = op.boundaries.map(b => b.map(shift).map(_pt))
      let seed = op.style.at("seed", default: auto-seed(("fill", bs)))
      let req = cbor.encode((
        boundaries: bs, style: engine-fill-style(s), seed: seed,
      ))
      render-paths(cbor(_engine.fill(req)).paths, s.color, s.opacity)
    }
  }
}

/// Hand-drawn canvas. Coordinates are floats in pt; `origin: "top-left"`
/// (default, y-down like Typst) or "bottom-left" (y-up, math convention).
///
/// ```typst
/// #sketch(180pt, 90pt,
///   line((10, 70), (160, 20)),
///   circle((90, 45), 25),
/// )
/// ```
///
/// The canvas intentionally does not clip, allowing rough outlines to extend
/// slightly beyond its nominal bounds.
///
/// - width (length): Canvas width.
/// - height (length): Canvas height.
/// - origin (str): `"top-left"` for y-down coordinates or `"bottom-left"`
///   for y-up coordinates. Default: `"top-left"`.
/// - ..elements (arguments): Shape operations returned by Chalks builders
///   such as `line`, `path`, `rect`, and `circle`.
#let sketch(width, height, origin: "top-left", ..elements) = {
  if origin not in ("top-left", "bottom-left") {
    panic("chalks: origin must be \"top-left\" or \"bottom-left\"")
  }
  let h = height.pt()
  let ops = elements.pos()
    .map(e => if type(e) == dictionary { (e,) } else { e })
    .flatten()
    .map(op => if origin == "bottom-left" { _flip(op, h) } else { op })
  block(width: width, height: height, clip: false, context render-ops(ops))
}
