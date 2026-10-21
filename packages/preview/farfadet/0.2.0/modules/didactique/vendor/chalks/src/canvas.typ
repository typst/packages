// The sketch canvas: flatten op arrays, resolve styles, call the engine,
// place the resulting curves in a sized block.
#import "engine.typ": _engine, _pt, chalks-decimation, poser-chemins
#import "style.typ": auto-seed, default-style, engine-fill-style, engine-stroke-style, validate-style
#import "theme.typ": theme-state

#let _flip(op, h) = {
  let fy(p) = (p.at(0), h - p.at(1))
  if op.op == "stroke" { op + (points: op.points.map(fy)) }
  else { op + (boundaries: op.boundaries.map(b => b.map(fy))) }
}

/// Version PURE de `render-ops` : le thème et le pas de décimation sont passés en arguments, si bien
/// que Typst mémoïse l'appel (moteur WASM compris) d'un emplacement à l'autre et d'un tour de mise en
/// page à l'autre (deux bandeaux de Démonstration identiques ne sont calculés qu'une fois).
#let _rendre-ops(ops, theme, pas) = {
  for op in ops {
    if type(op) != dictionary or "op" not in op or op.op not in ("stroke", "fill") {
      panic("chalks: sketch elements must be shape ops, got " + repr(op))
    }
    // = resolve-style(op.style), le thème étant lu par l'appelant
    validate-style(op.style)
    let s = default-style + theme + op.style
    if op.op == "stroke" {
      let pts = op.points.map(_pt)
      let seed = if "seed" in op.style { op.style.seed } else { auto-seed(("stroke", pts, op.closed)) }
      let req = cbor.encode((
        points: pts, closed: op.closed, style: engine-stroke-style(s), seed: seed,
      ))
      poser-chemins(cbor(_engine.stroke(req)).paths, s.color, s.opacity, pas)
    } else {
      let bs = op.boundaries.map(b => b.map(_pt))
      let seed = if "seed" in op.style { op.style.seed } else { auto-seed(("fill", bs)) }
      let req = cbor.encode((
        boundaries: bs, style: engine-fill-style(s), seed: seed,
      ))
      poser-chemins(cbor(_engine.fill(req)).paths, s.color, s.opacity, pas)
    }
  }
}

/// Render shape operations in the caller's coordinate frame (dans un `context`).
#let render-ops(ops) = _rendre-ops(ops, theme-state.get(), chalks-decimation.get())

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
#let sketch(width, height, origin: "top-left", ..elements) = context {
  if origin not in ("top-left", "bottom-left") {
    panic("chalks: origin must be \"top-left\" or \"bottom-left\"")
  }
  let h = height.to-absolute().pt()
  let ops = elements.pos()
    .map(e => if type(e) == dictionary { (e,) } else { e })
    .flatten()
    .map(op => if origin == "bottom-left" { _flip(op, h) } else { op })
  block(width: width, height: height, clip: false, render-ops(ops))
}
