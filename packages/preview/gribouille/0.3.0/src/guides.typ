///! Plot-level guide bindings.
///!
///! Map aesthetic names to guide specs built with \@guide-legend, pass `none`
///! to hide a guide, and feed the result to \@plot via the `guides:` parameter.

#import "utils/errors.typ": fail

/// Bind guide specifications to aesthetics.
///
/// Accepts named arguments where each key is an aesthetic (e.g., `colour`, `fill`) and each value is a guide spec from `guide-legend`, `none` to hide that guide, or `auto` for the default. The resulting dictionary threads into the plot spec and is honoured by the legend renderer. For the `x` / `y` axes, `none` hides the axis ticks and tick labels (the axis line and title stay; remove the title with `labs(x: none)`); under `coord-radial`, `theta` / `r` `none` hide the angular / radial axis labels while the spokes and circles stay.
///
/// - args: Named guide specs keyed by aesthetic name.
///   - colour: a guide spec from `guide-legend` for the `colour` aesthetic, `none` to hide it, or `auto` for the default.
///   - fill: a guide spec from `guide-legend` for the `fill` aesthetic, `none` to hide it, or `auto` for the default.
///   - size: a guide spec from `guide-legend` for the `size` aesthetic, `none` to hide it, or `auto` for the default.
///   - alpha: a guide spec from `guide-legend` for the `alpha` aesthetic, `none` to hide it, or `auto` for the default.
///   - linewidth: a guide spec from `guide-legend` for the `linewidth` aesthetic, `none` to hide it, or `auto` for the default.
///   - shape: a guide spec from `guide-legend` for the `shape` aesthetic, `none` to hide it, or `auto` for the default.
///   - linetype: a guide spec from `guide-legend` for the `linetype` aesthetic, `none` to hide it, or `auto` for the default.
///   - stroke: a guide spec from `guide-legend` for the `stroke` aesthetic, `none` to hide it, or `auto` for the default.
///   - x: a guide spec from `guide-legend` for the `x` aesthetic, `none` to hide it, or `auto` for the default.
///   - y: a guide spec from `guide-legend` for the `y` aesthetic, `none` to hide it, or `auto` for the default.
///   - theta: a guide spec from `guide-legend` for the `theta` aesthetic, `none` to hide it, or `auto` for the default.
///   - r: a guide spec from `guide-legend` for the `r` aesthetic, `none` to hide it, or `auto` for the default.
///   - default: a fallback guide whose unset fields (e.g. an `auto` `position`) are inherited by every aesthetic without its own override, so `guides(default: guide-legend(position: "bottom"))` moves all legends to the bottom in one call; `guides(default: none)` hides every legend that has no override of its own.
///
/// Returns: Dictionary mapping aesthetic name to guide spec.
///
/// See also: `guide-legend`, `plot`.
///
/// Lay the colour legend out across two columns.
///
/// ```typst
/// #let d = (
///   (x: 1, y: 1, g: "a"),
///   (x: 2, y: 2, g: "b"),
///   (x: 3, y: 3, g: "c"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "g"),
///   layers: (geom-point(size: 3pt),),
///   guides: guides(colour: guide-legend(ncolumn: 2)),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Combine `guide-axis` and `none` to rotate x ticks and hide the redundant fill legend in one call.
///
/// ```typst
/// #let d = (
///   (x: "January", y: 1, g: "a"),
///   (x: "February", y: 2, g: "a"),
///   (x: "March", y: 3, g: "b"),
///   (x: "April", y: 4, g: "b"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", fill: "g"),
///   layers: (geom-col(),),
///   guides: guides(
///     x: guide-axis(angle: 30),
///     fill: none,
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// Use `default` to place every legend at the bottom in one call; the per-aesthetic `colour` override inherits that side and only changes its column count.
///
/// ```typst
/// #let d = (
///   (x: 1, y: 1, g: "a", s: "p"),
///   (x: 2, y: 2, g: "b", s: "q"),
///   (x: 3, y: 3, g: "c", s: "p"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "g", shape: "s"),
///   layers: (geom-point(size: 3pt),),
///   guides: guides(
///     default: guide-legend(position: "bottom"),
///     colour: guide-legend(ncolumn: 3),
///   ),
///   width: 9cm,
///   height: 6cm,
/// )
/// ```
#let guides(..args) = {
  let out = (:)
  for (k, v) in args.named() {
    if v == auto {
      continue
    } else if v == none {
      out.insert(k, (kind: "guide", suppress: true))
    } else if type(v) == dictionary {
      out.insert(k, v)
    } else {
      fail(
        "guides",
        "value for '"
          + k
          + "' must be a guide spec (e.g. guide-legend, guide-axis), `none` to"
          + " hide the guide, or `auto` for the default; got "
          + repr(v),
      )
    }
  }
  out
}
