///! Theta-axis guide for radial coordinates.
///!
///! Bind via \@guides as `theta: guide-axis-theta(...)` to customise the
///! angular axis of a \@coord-radial plot: rotate tick labels, emit minor
///! ticks at half-step positions, or trim the axis arc at one or both ends.

/// Customise the theta (angular) axis under `coord-radial`.
///
/// The returned spec carries customisation only; it is bound to the theta axis when passed through `guides` as `theta: guide-axis-theta(...)`, and applied by the radial axis renderer. When bound the renderer draws an outer axis arc spanning the active theta range; without it the radial axis remains spoke-only. The major tick marks need no guide: they follow the `axis-ticks` theme surface, as they do on a cartesian axis.
///
/// - angle: Tick-label rotation in degrees: 0 horizontal, 45 readable diagonal, 90 vertical.
/// - minor-ticks: Whether to draw short tick marks at half-step positions between major theta breaks, on the `axis-ticks-minor` theme surface.
/// - cap: Where to trim the axis arc: `"none"` (full sweep), `"both"`, `"upper"`, or `"lower"`.
///
/// Returns: Guide dictionary tagged `kind: "guide"`, consumed by `guides`.
///
/// See also: `guides`, `guide-axis`, `coord-radial`.
///
/// Rotate theta tick labels on a radar plot. The arc and the tick marks read the `axis-line` and `axis-ticks` theme surfaces, which `theme-minimal` blanks, so this turns them back on.
///
/// ```typst
/// #let d = (
///   (axis: "speed", value: 4),
///   (axis: "comfort", value: 3),
///   (axis: "range", value: 5),
///   (axis: "boot", value: 2),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "axis", y: "value"),
///   layers: (geom-col(),),
///   coord: coord-radial(),
///   guides: guides(theta: guide-axis-theta(angle: 30, minor-ticks: true)),
///   theme: theme-minimal(
///     axis-line: element-line(stroke: 0.5pt),
///     axis-ticks: element-tick(length: 0.15cm),
///   ),
///   width: 8cm,
///   height: 8cm,
/// )
/// ```
#let guide-axis-theta(
  angle: 0,
  minor-ticks: false,
  cap: "none",
) = (
  kind: "guide",
  name: "axis-theta",
  aesthetic: "theta",
  angle: angle,
  minor-ticks: minor-ticks,
  cap: cap,
)
