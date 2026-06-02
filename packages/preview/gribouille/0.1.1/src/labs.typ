///! Plot-level labels: title, subtitle, caption, and per-aesthetic names.
///!
///! The result feeds \@plot, which draws the title block and forwards axis names
///! into the trained scales so axis and legend titles follow.

/// Build a label dictionary for the plot title, subtitle, caption, and axes.
///
/// Pass the result to \@plot as the `labs` argument.
/// Axis names (x, y, colour, fill, ...) override the corresponding scale
/// `name` at render time, so legends and axis titles pick them up.
///
/// \@category Labs
/// \@stability stable
/// \@since 0.0.1
///
/// \@param title Plot title drawn above the panel.
///
/// \@param subtitle Smaller line drawn below the title.
///
/// \@param caption Caption line drawn below the panel.
///
/// \@param tag Optional tag (e.g., a figure number) drawn above the title.
///
/// \@param alt Alt text kept on the spec for accessibility tooling.
///
/// \@param x Title for the x axis.
///
/// \@param y Title for the y axis.
///
/// \@param colour Legend title for the colour aesthetic.
///
/// \@param fill Legend title for the fill aesthetic.
///
/// \@param size Legend title for the size aesthetic.
///
/// \@param alpha Legend title for the alpha aesthetic.
///
/// \@param linewidth Legend title for the linewidth aesthetic.
///
/// \@param shape Legend title for the shape aesthetic.
///
/// \@param linetype Legend title for the linetype aesthetic.
///
/// \@param stroke Legend title for the stroke aesthetic.
///
/// \@returns Dictionary tagged `kind: "labs"`, consumed by \@plot.
///
/// \@examples Title block plus axis titles passed via `labs`.
/// ```
/// //| alt: "Scatter chart with a 'Demo' title, 'A tiny dataset' subtitle, 'Source: made up' caption, and 'Index' / 'Value' axis titles set via labs."
/// #let d = (
///   (x: 1, y: 2),
///   (x: 2, y: 4),
///   (x: 3, y: 3),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y"),
///   layers: (geom-point(size: 3pt),),
///   labs: labs(
///     title: "Demo",
///     subtitle: "A tiny dataset",
///     caption: "Source: made up",
///     x: "Index",
///     y: "Value",
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Setting an aesthetic name (`colour`) overrides the legend
/// title; alt text is stored on the spec for accessibility tooling.
/// ```
/// //| alt: "Scatter chart titled 'Coloured Groups' with three points coloured by species and the colour legend retitled 'Species' via labs."
/// #let d = (
///   (x: 1, y: 2, sp: "a"),
///   (x: 2, y: 4, sp: "b"),
///   (x: 3, y: 3, sp: "c"),
/// )
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "sp"),
///   layers: (geom-point(size: 3pt),),
///   labs: labs(
///     title: "Coloured Groups",
///     colour: "Species",
///     alt: "Three points coloured by species",
///   ),
///   width: 10cm,
///   height: 6cm,
/// )
/// ```
///
/// \@examples Full label block on the penguins scatter: title, subtitle,
/// caption, axis titles, and a legend title for the `fill` aesthetic.
/// ```
/// //| alt: "Scatter of penguin body mass against flipper length coloured by species, with full title, subtitle, caption, axis titles, and a 'Species' fill legend title via labs."
/// #plot(
///   data: penguins,
///   mapping: aes(x: "flipper-len", y: "body-mass", fill: "species"),
///   layers: (geom-point(size: 2pt, alpha: 0.85),),
///   labs: labs(
///     title: "Penguin Body Mass Scales with Flipper Length",
///     subtitle: "Three species across the Palmer Archipelago",
///     caption: "Data: palmerpenguins (Horst, Hill & Gorman, 2020)",
///     x: "Flipper Length (mm)",
///     y: "Body Mass (g)",
///     fill: "Species",
///     alt: "Scatter of body mass against flipper length, coloured by species.",
///   ),
///   width: 12cm,
///   height: 7cm,
/// )
/// ```
///
/// \@see \@plot
#let labs(
  title: none,
  subtitle: none,
  caption: none,
  tag: none,
  alt: none,
  x: none,
  y: none,
  colour: none,
  fill: none,
  size: none,
  alpha: none,
  linewidth: none,
  shape: none,
  linetype: none,
  stroke: none,
) = (
  kind: "labs",
  title: title,
  subtitle: subtitle,
  caption: caption,
  tag: tag,
  alt: alt,
  axes: (
    x: x,
    y: y,
    colour: colour,
    fill: fill,
    size: size,
    alpha: alpha,
    linewidth: linewidth,
    shape: shape,
    linetype: linetype,
    stroke: stroke,
  ),
)
