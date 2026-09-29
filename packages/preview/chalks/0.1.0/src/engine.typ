// WASM bridge: CBOR in/out to chalks-engine. Styling stays in Typst.
#import "style.typ": auto-seed, engine-fill-style, engine-stroke-style, resolve-style

#let _engine = plugin("../plugin/chalks_engine.wasm")

/// Returns the bundled Chalks WASM engine version string.
///
/// This is mainly useful for diagnostics and package smoke tests.
#let engine-version() = str(_engine.version())

// Round to 1e-6 pt: calc.sin/cos/exp go through the platform math library,
// whose last-ULP results vary across OSes; unrounded they would re-roll
// auto-seed and make committed example images irreproducible in CI.
#let _pt(p) = (
  calc.round(float(p.at(0)), digits: 6),
  calc.round(float(p.at(1)), digits: 6),
)

/// Engine paths -> filled curve elements, placed at (0,0) of the caller's
/// frame. weight scales opacity (shade layering).
#let render-paths(paths, color, opacity) = {
  for p in paths {
    let elems = ()
    for sp in p.subpaths {
      elems.push(curve.move((sp.start.at(0) * 1pt, sp.start.at(1) * 1pt)))
      for c in sp.cubics {
        elems.push(curve.cubic(
          (c.at(0).at(0) * 1pt, c.at(0).at(1) * 1pt),
          (c.at(1).at(0) * 1pt, c.at(1).at(1) * 1pt),
          (c.at(2).at(0) * 1pt, c.at(2).at(1) * 1pt),
        ))
      }
      elems.push(curve.close())
    }
    let alpha = calc.max(0%, 100% - opacity * p.weight)
    place(top + left, curve(
      fill: color.transparentize(alpha),
      fill-rule: "even-odd",
      ..elems,
    ))
  }
}

/// Draws a low-level hand-sketched stroke directly through explicit points.
///
/// Prefer `path` inside `sketch` for normal figures. This function bypasses
/// shape builders and returns placed content directly.
///
/// - points (array): Two or more `(x, y)` points as numbers in points, with
///   positive y downward.
/// - closed (bool): Join the last point to the first. Default: `false`.
/// - style (dictionary): Engine stroke keys: `smoothness`, `roughness`,
///   `width`, `taper`, and `passes`; rendering keys `color` and `opacity` are
///   also accepted. Default: `(:)`.
/// - seed (auto, int): Deterministic RNG seed; `auto` derives one from the
///   geometry. Default: `auto`.
#let raw-stroke(points, closed: false, style: (:), seed: auto) = context {
  let s = resolve-style(style)
  let pts = points.map(_pt)
  let seed = if seed == auto { auto-seed(("stroke", pts, closed)) } else { seed }
  let req = cbor.encode((
    points: pts,
    closed: closed,
    style: engine-stroke-style(s),
    seed: seed,
  ))
  render-paths(cbor(_engine.stroke(req)).paths, s.color, s.opacity)
}

/// Draws a low-level fill directly from explicit closed boundary rings.
///
/// Nested rings are holes under the even-odd rule. Prefer a filled shape or
/// `region` inside `sketch` for normal figures.
///
/// - boundaries (array): Array of rings, each containing at least three
///   `(x, y)` points as numbers in points, with positive y downward.
/// - style (dictionary): Fill keys: `pattern` (`"hachure"` or `"shade"`),
///   `smoothness`, `roughness`, `width`, `angle`, and `spacing`; `color` and
///   `opacity` are also accepted. Default: `(:)`.
/// - seed (auto, int): Deterministic RNG seed; `auto` derives one from the
///   boundaries. Default: `auto`.
#let raw-fill(boundaries, style: (:), seed: auto) = context {
  let s = resolve-style(style)
  let bs = boundaries.map(b => b.map(_pt))
  let seed = if seed == auto { auto-seed(("fill", bs)) } else { seed }
  let req = cbor.encode((
    boundaries: bs,
    style: engine-fill-style(s),
    seed: seed,
  ))
  render-paths(cbor(_engine.fill(req)).paths, s.color, s.opacity)
}
