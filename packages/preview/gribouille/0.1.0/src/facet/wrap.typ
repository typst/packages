///! Wrap faceting.
///!
///! One panel per level of a discrete variable, wrapped into a grid of
///! `ncolumn` columns (or `nrow` rows).

#import "labellers.typ": label-value

/// Wrap facets: one panel per level of a discrete variable.
///
/// Panels are arranged into a grid of `ncolumn` columns (or `nrow` rows
/// when `ncolumn` is `none`).
///
/// \@category Facets
/// \@stability stable
/// \@since 0.0.1
///
/// \@param variable Name of the discrete column whose levels drive the panels.
///
/// \@param ncolumn Number of columns in the panel grid, or `none` for automatic.
///
/// \@param nrow Number of rows in the panel grid, or `none` for automatic.
///
/// \@param scales Scale policy. One of `"fixed"` (default, every panel
///   shares both axes), `"free"` (each panel trains x and y on its own
///   subset), `"free_x"` (only x is per-panel), or `"free_y"` (only y is
///   per-panel). Non-positional scales (colour, fill, size, shape,
///   linetype) are always shared so legends stay consistent. An explicit
///   `coord-cartesian(xlim:, ylim:)` overrides the per-panel domain on
///   the corresponding axis, pinning every panel to the same range.
///
/// \@param labeller Labeller controlling strip text. Defaults to
///   `label-value()` which shows the level as-is.
///
/// \@param axes Which panels draw their own positional axes. One of
///   `"margins"` (default; outer edge plus any panel whose neighbour slot
///   is empty), `"all_x"` (every panel draws bottom and top x axes),
///   `"all_y"` (every panel draws left and right y axes), or `"all"`
///   (every panel draws both). Independent of `scales`: with the default
///   `"margins"`, a panel above an empty trailing slot still gets a
///   bottom x axis.
///
/// \@returns Facet dictionary consumed by \@plot.
///
/// \@examples One panel per level of `sp`, three columns, with each panel
/// training y independently.
/// ```
/// //| alt: "Three scatter panels in one row, one per sp level (a, b, c), with shared x axis and per-panel free y axes so each panel's y range matches its own data."
/// #let d = ()
/// #for sp in ("a", "b", "c") {
///   for i in range(0, 6) {
///     d.push((sp: sp, x: i, y: i + calc.rem(i, 3)))
///   }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   facet: facet-wrap("sp", ncolumn: 3, scales: "free_y"),
///   width: 12cm,
///   height: 7cm,
/// )
/// ```
///
/// \@examples Default `scales: "fixed"` shares both axes across panels;
/// useful when you want comparable scales side by side.
/// ```
/// //| alt: "Four scatter panels in a 2-by-2 grid, one per sp level (a-d), all sharing the same x and y axes for direct visual comparison."
/// #let d = ()
/// #for sp in ("a", "b", "c", "d") {
///   for i in range(0, 6) {
///     d.push((sp: sp, x: i, y: i + calc.rem(i, 3)))
///   }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   facet: facet-wrap("sp", nrow: 2),
///   width: 12cm,
///   height: 7cm,
/// )
/// ```
///
/// \@examples One panel per penguin island, sharing axes so the species
/// clusters can be compared visually across panels.
/// ```
/// //| alt: "Three scatter panels of body mass against flipper length, one per penguin island, with points filled by species so species clusters can be compared across islands."
/// #plot(
///   data: penguins,
///   mapping: aes(
///     x: "flipper-len",
///     y: "body-mass",
///     fill: "species",
///   ),
///   layers: (geom-point(size: 2pt, alpha: 0.85),),
///   facet: facet-wrap("island", ncolumn: 3),
///   labs: labs(x: "Flipper Length (mm)", y: "Body Mass (g)", fill: "Species"),
///   width: 14cm,
///   height: 5cm,
/// )
/// ```
///
/// \@see \@facet-grid, \@plot
#let facet-wrap(
  variable,
  ncolumn: none,
  nrow: none,
  scales: "fixed",
  labeller: label-value(),
  axes: "margins",
) = {
  if not ("fixed", "free", "free_x", "free_y").contains(scales) {
    panic(
      "facet-wrap: scales must be \"fixed\", \"free\", \"free_x\", or \"free_y\"",
    )
  }
  if not ("margins", "all_x", "all_y", "all").contains(axes) {
    panic(
      "facet-wrap: axes must be \"margins\", \"all_x\", \"all_y\", or \"all\"",
    )
  }
  (
    kind: "facet",
    facet: "wrap",
    variable: variable,
    ncolumn: ncolumn,
    nrow: nrow,
    scales: scales,
    labeller: labeller,
    axes: axes,
  )
}

