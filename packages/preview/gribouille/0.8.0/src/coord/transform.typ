///! Coordinate-level transformation via `coord_transform()`.

#import "../scale/arguments.typ": _TRANSFORMS
#import "../utils/errors.typ": fail-enum
#import "contract.typ": coord-base
#import "expand.typ": apply-expand

// coord-transform warps the view at mapping time. Skips axes whose scale
// already pre-transformed the data: pre- and post-stat warps don't compose.
#let _apply-coord-transform(trained, transforms) = {
  for axis in ("x", "y") {
    let t = transforms.at(axis)
    if t == "identity" { continue }
    let entry = trained.at(axis, default: none)
    if entry == none or entry.type != "continuous" { continue }
    if entry.at("pre-transformed", default: false) { continue }
    let new-entry = entry
    new-entry.insert("transform", t)
    trained.insert(axis, new-entry)
  }
  trained
}

/// Transform the displayed coordinates after statistics have run.
///
/// Sets the per-axis `transform` so the trained scale's view is warped at mapping time. Accepts the same keywords as `scale-continuous`'s `transform:` parameter: `"identity"`, `"log10"`, `"sqrt"`, `"reverse"`.
///
/// When a positional scale already sets `transform:`, `coord-transform` overrides it for that axis.
///
/// - x: Transformation keyword for the x axis.
/// - y: Transformation keyword for the y axis.
///
/// Returns: Coordinate dictionary consumed by `plot`.
///
/// See also: `plot`, `scale-continuous`.
///
/// Log10 the x and y axes without setting `transform:` on each scale.
///
/// ```typst
/// #let d = (
///   (x: 1, y: 1),
///   (x: 10, y: 100),
///   (x: 100, y: 10000),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 3pt),),
///   coord: coord-transform(x: "log10", y: "log10"),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let coord-transform(x: "identity", y: "identity") = {
  if x not in _TRANSFORMS { fail-enum("coord-transform", "x", x, _TRANSFORMS) }
  if y not in _TRANSFORMS { fail-enum("coord-transform", "y", y, _TRANSFORMS) }
  (
    coord-base("transform")
      + (
        x: x,
        y: y,
        train: trained => apply-expand(
          _apply-coord-transform(trained, (x: x, y: y)),
        ),
      )
  )
}
