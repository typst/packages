///! Top-level shortcut for extending axis domains.
///!
///! `expand-limits` folds extra values into the trained min/max so the final
///! domain spans both the data and the supplied points, without clipping.
///! For clipping use \@scale-continuous with its `limits:` argument directly.

#import "scale/continuous.typ": _continuous-scale
#import "utils/errors.typ": fail-type
#import "utils/types.typ": parse-number

/// Ensure the trained domain includes the supplied values without replacing it.
///
/// `expand-limits` does not clip the data; it folds `extend` values into the trained min/max so the final domain spans both the data and the supplied points. Useful for forcing a baseline at zero or showing a target value alongside observed data.
///
/// - x: Single value or array of values the x-axis must include, or `none`.
/// - y: Single value or array of values the y-axis must include, or `none`.
///
/// Returns: Aesthetic-keyed dictionary of scale specs ready to pass to `scales:` on `plot`.
///
/// See also: `scale-continuous`, `scales`.
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
  // A value here is a user argument, not a data cell, so one that does not
  // parse fails, as a scale limit does.
  let _values(name, v) = {
    let values = if type(v) == array { v } else { (v,) }
    for value in values {
      if parse-number(value) == none {
        fail-type(
          "expand-limits",
          name,
          value,
          "a number or an ISO date string",
        )
      }
    }
    values
  }
  let out = (:)
  if x != none {
    let s = _continuous-scale("x")
    s.insert("extend", _values("x", x))
    out.insert("x", s)
  }
  if y != none {
    let s = _continuous-scale("y")
    s.insert("extend", _values("y", y))
    out.insert("y", s)
  }
  out
}
