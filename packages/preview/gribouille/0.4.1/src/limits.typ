///! Top-level shortcut for extending axis domains.
///!
///! `expand-limits` folds extra values into the trained min/max so the final
///! domain spans both the data and the supplied points, without clipping.
///! For clipping use \@scale-x-continuous and \@scale-y-continuous with their
///! `limits:` argument directly.

#import "scale/continuous.typ": scale-x-continuous, scale-y-continuous

/// Ensure the trained domain includes the supplied values without replacing it.
///
/// `expand-limits` does not clip the data; it folds `extend` values into the trained min/max so the final domain spans both the data and the supplied points. Useful for forcing a baseline at zero or showing a target value alongside observed data.
///
/// - x: Single value or array of values the x-axis must include, or `none`.
/// - y: Single value or array of values the y-axis must include, or `none`.
///
/// Returns: Array of scale specs ready to splat into `scales:` on `plot`.
///
/// See also: `scale-x-continuous`, `scale-y-continuous`.
///
/// Force a y baseline at zero so positive observations sit above the axis floor.
///
/// ```typst
/// #let d = range(1, 6).map(i => (x: i, y: i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 3pt),),
///   scales: expand-limits(y: 0),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Pass arrays to extend both axes towards multiple targets at once, useful for highlighting a reference value.
///
/// ```typst
/// #let d = range(1, 6).map(i => (x: i, y: i))
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 3pt),),
///   scales: expand-limits(x: (0, 10), y: (0, 10)),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let expand-limits(x: none, y: none) = {
  let _values(v) = if type(v) == array { v } else { (v,) }
  let out = ()
  if x != none {
    let s = scale-x-continuous()
    s.insert("extend", _values(x))
    out.push(s)
  }
  if y != none {
    let s = scale-y-continuous()
    s.insert("extend", _values(y))
    out.push(s)
  }
  out
}
