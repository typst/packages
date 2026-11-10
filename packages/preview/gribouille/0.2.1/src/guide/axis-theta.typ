///! Theta-axis guide for radial coordinates.
///!
///! Bind via \@guides as `theta: guide-axis-theta(...)` to customise the
///! angular axis of a \@coord-radial plot: rotate tick labels, emit minor
///! ticks at half-step positions, or trim the axis arc at one or both ends.

/// Customise the theta (angular) axis under \@coord-radial.
///
/// The returned spec carries customisation only; it is bound to the theta
/// axis when passed through \@guides as `theta: guide-axis-theta(...)`, and
/// applied by the radial axis renderer. When bound the renderer draws an
/// outer axis arc spanning the active theta range; without it the radial
/// axis remains spoke-only.
///
/// \@category Guides
/// \@stability stable
/// \@since 0.5.0
///
/// \@param angle Tick-label rotation in degrees: 0 horizontal, 45 readable diagonal, 90 vertical.
///
/// \@param minor-ticks Whether to draw short tick marks at half-step positions between major theta breaks.
///
/// \@param cap Where to trim the axis arc: `"none"` (full sweep), `"both"`, `"upper"`, or `"lower"`.
///
/// \@returns Guide dictionary tagged `kind: "guide"`, consumed by \@guides.
///
/// \@examples Rotate theta tick labels on a radar plot.
/// ```
/// //| alt: "Radial bar chart with theta-axis category labels tilted 30 degrees and minor ticks between major spokes."
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
///   width: 8cm,
///   height: 8cm,
/// )
/// ```
///
/// \@see \@guides, \@guide-axis, \@coord-radial
#let guide-axis-theta(
  angle: 0,
  minor-ticks: false,
  cap: "none",
) = (
  kind: "guide",
  aesthetic: "theta",
  angle: angle,
  minor-ticks: minor-ticks,
  cap: cap,
)
