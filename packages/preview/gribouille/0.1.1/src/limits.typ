///! Top-level shortcut for extending axis domains.
///!
///! `expand-limits` folds extra values into the trained min/max so the final
///! domain spans both the data and the supplied points, without clipping.
///! For clipping use \@scale-x-continuous and \@scale-y-continuous with their
///! `limits:` argument directly.

#import "scale/continuous.typ": scale-x-continuous, scale-y-continuous

/// Ensure the trained domain includes the supplied values without replacing it.
///
/// `expand-limits` does not clip the data; it folds `extend` values into the
/// trained min/max so the final domain spans both the data and the supplied
/// points. Useful for forcing a baseline at zero or showing a target value
/// alongside observed data.
///
/// \@category Scales
/// \@stability stable
/// \@since 0.0.1
///
/// \@param x Single value or array of values the x-axis must include, or `none`.
///
/// \@param y Single value or array of values the y-axis must include, or `none`.
///
/// \@returns Array of scale specs ready to splat into `scales:` on \@plot.
///
/// \@examples Force a y baseline at zero so positive observations sit above
/// the axis floor.
/// ```
/// //| alt: "Scatter chart of y against x whose y axis is extended to include zero via expand-limits, so all positive points sit above the baseline."
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
/// \@examples Pass arrays to extend both axes towards multiple targets at
/// once, useful for highlighting a reference value.
/// ```
/// //| alt: "Scatter chart of y against x with both axes extended to span zero to ten via expand-limits, leaving extra empty space around the data."
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
///
/// \@see \@scale-x-continuous, \@scale-y-continuous
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
