///! Plot-level guide bindings.
///!
///! Map aesthetic names to guide specs built with \@guide-legend or
///! \@guide-none, and pass the result to \@plot via the `guides:` parameter.

/// Bind guide specifications to aesthetics.
///
/// Accepts named arguments where each key is an aesthetic (e.g., `colour`,
/// `fill`) and each value is a guide spec from \@guide-legend or \@guide-none.
/// The resulting dictionary threads into the plot spec and is honoured by
/// the legend renderer.
///
/// \@category Guides
/// \@stability stable
/// \@since 0.0.1
///
/// \@param args Named guide specs keyed by aesthetic name.
///
/// \@returns Dictionary mapping aesthetic name to guide spec.
///
/// \@examples Lay the colour legend out across two columns.
/// ```
/// //| alt: "Scatter chart with three points coloured by group whose colour legend is laid out across two columns via guide-legend(ncolumn: 2)."
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
/// \@examples Combine `guide-axis` and `guide-none` to rotate x ticks and
/// hide the redundant fill legend in one call.
/// ```
/// //| alt: "Bar chart of y per month with x tick labels rotated thirty degrees via guide-axis and the fill legend suppressed via guide-none."
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
///     fill: guide-none(),
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see \@guide-legend, \@guide-none, \@plot
#let guides(..args) = {
  let out = (:)
  for (k, v) in args.named() {
    out.insert(k, v)
  }
  out
}
