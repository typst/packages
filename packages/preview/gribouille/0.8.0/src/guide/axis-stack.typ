///! Stack multiple position guides on a single axis.
///!
///! Bind via \@guides as `x: guide-axis-stack(...)` or `y: guide-axis-stack(...)`
///! to render several axis-guide passes on the same side of a panel — for
///! example a rotated-label \@guide-axis above a \@guide-axis-logticks pass.

#import "../utils/errors.typ": fail-type

/// Stack multiple x or y guides on a single axis.
///
/// Each sub-guide is rendered as an independent label row using its own `angle` and `n-dodge`; rows are separated vertically (x axis) or horizontally (y axis) by `spacing`. Any sub-guide with `logticks: true` also draws minor log ticks on a `transform: "log10"` axis. Tick label content is shared across rows; only the styling varies.
///
/// - guides: Non-empty array of `guide-axis` or `guide-axis-logticks` specs to render in order from the axis outward. Required, and passed first.
/// - spacing: Gap inserted between successive sub-guide rows, a length of at least 0.
///
/// Returns: Guide dictionary tagged `kind: "guide"` with `stack: true`, consumed by `guides`.
///
/// See also: `guide-axis`, `guide-axis-logticks`, `guides`.
///
/// Stack a rotated-label pass above the default log minor ticks so a log10 x axis carries both readable labels and dense tick marks.
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
///   scales: scales(
///     x: scale-continuous(transform: "log10"),
///     y: scale-continuous(transform: "log10"),
///   ),
///   guides: guides(
///     x: guide-axis-stack((
///       guide-axis(angle: 30),
///       guide-axis-logticks(),
///     )),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
#let guide-axis-stack(guides, spacing: 4pt) = {
  let valid = type(guides) == array and guides.len() > 0
  if valid {
    for g in guides {
      if (
        type(g) != dictionary
          or g.at("name", default: none) not in ("axis", "axis-logticks")
      ) {
        valid = false
      }
    }
  }
  if not valid {
    fail-type(
      "guide-axis-stack",
      "guides",
      guides,
      "a non-empty array of `guide-axis()` or `guide-axis-logticks()` specs",
      hint: "Pass the array first: `guide-axis-stack((guide-axis(), guide-axis-logticks()))`.",
    )
  }
  if type(spacing) != length or spacing.abs < 0pt or spacing.em < 0 {
    fail-type(
      "guide-axis-stack",
      "spacing",
      spacing,
      "a length of at least 0, such as `4pt`",
    )
  }
  (
    kind: "guide",
    name: "axis-stack",
    aesthetic: none,
    stack: true,
    guides: guides,
    spacing: spacing,
  )
}
