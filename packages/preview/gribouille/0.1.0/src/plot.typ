#import "render.typ": render-plot
#import "data.typ": _normalise-data

/// Compose a layered plot from data, aesthetics, and geom layers.
///
/// `plot` is the entry point of the grammar: it resolves the dataset, wires up
/// the aesthetic mapping, trains scales against the data, applies coordinate,
/// facet, theme, and label choices, and dispatches to the internal renderer.
/// Call it once per figure, passing the layers you want to stack.
///
/// \@category Core
/// \@stability stable
/// \@since 0.0.1
///
/// \@param data Either an array of row dictionaries (one row per observation, e.g., `((x: 1, y: 2), (x: 3, y: 4))`) or a dictionary of equal-length column arrays (e.g., `(x: (1, 3), y: (2, 4))`). Column-store input is normalised to row-store internally.
///
/// \@param mapping Aesthetic mapping built with\@aes. Maps column names to visual channels.
///
/// \@param layers Array of geom layers (e.g., \@geom-point,\@geom-line). Drawn in order.
///
/// \@param scales Array of scale objects overriding defaults \@scale-x-continuous,\@scale-colour-viridis-d, etc.).
///
/// \@param coord Coordinate system. Defaults to\@coord-cartesian when `none`.
///
/// \@param facet Faceting specification built with\@facet-wrap or\@facet-grid.
///
/// \@param theme Theme object (e.g., \@theme-grey,\@theme-minimal,\@theme-classic). Controls non-data ink.
///
/// \@param labs Labels dictionary built with\@labs (title, subtitle, caption, axis titles).
///
/// \@param guides Per-aesthetic guide overrides built with\@guides (e.g., `guides(colour: guide-legend(reverse: true))`).
///
/// \@param width Total plot width, including axes and legends.
///
/// \@param height Total plot height, including axes and legends.
///
/// \@param alt Alt text describing the figure. When set, the rendered plot is wrapped in a `figure` (kind `"gribouille-plot"`, no number, no caption) carrying this string as its PDF alternative text, so a screen reader on a tagged PDF announces the description instead of the raw axis and legend labels. When `none`, the plot renders without the figure wrapper. Quarto authors embedding plots through `typst-render` should set the block-level `alt` cell option for HTML output; this parameter only affects direct Typst compilation.
///
/// \@param strict When `true`, panic on the first row whose value falls outside any user-supplied scale `limits`. Default `false` drops such rows silently. Use in docs and CI to surface mismatched limits rather than producing thinned-out plots.
///
/// \@param defer When `true`, return the spec dict instead of rendering, so\@compose can probe guides and re-render with hoisted aesthetics suppressed. The dict carries the same keys the renderer would consume; do not feed it to anything other than\@compose.
///
/// \@returns Typst content block containing the rendered figure, or the spec dict when `defer: true`.
///
/// \@examples Single-layer scatter coloured by category, with a title.
/// ```
/// //| alt: "Scatter chart of fuel economy against weight for five cars, coloured by cylinder count, titled 'Fuel Economy vs. Weight'."
/// #let mtcars = (
///   (mpg: 21.0, wt: 2.620, cyl: "6"),
///   (mpg: 22.8, wt: 2.320, cyl: "4"),
///   (mpg: 18.7, wt: 3.440, cyl: "8"),
///   (mpg: 16.4, wt: 4.070, cyl: "8"),
///   (mpg: 33.9, wt: 1.835, cyl: "4"),
/// )
/// #plot(
///   data: mtcars,
///   mapping: aes(x: "wt", y: "mpg", colour: "cyl"),
///   layers: (geom-point(size: 3pt),),
///   labs: labs(title: "Fuel Economy vs. Weight"),
///   width: 12cm,
///   height: 7cm,
/// )
/// ```
///
/// \@examples Stack two layers (`geom-point` + `geom-smooth`) and apply a
/// theme, scales, and facets in one call.
/// ```
/// //| alt: "Two-panel faceted scatter of y against x with linear smooth fits per group, coloured by group, drawn on the minimal theme and titled 'Per-Group Trend'."
/// #let d = ()
/// #for grp in ("a", "b") {
///   for i in range(0, 12) {
///     d.push((x: i, y: i * 0.5 + (if grp == "b" { 1 } else { 0 }) + calc.sin(i), grp: grp))
///   }
/// }
/// #plot(
///   data: d,
///   mapping: aes(x: "x", y: "y", colour: "grp"),
///   layers: (
///     geom-point(size: 2pt),
///     geom-smooth(method: "lm", se: false),
///   ),
///   facet: facet-wrap("grp"),
///   theme: theme-minimal(),
///   labs: labs(title: "Per-Group Trend"),
///   width: 12cm,
///   height: 6cm,
/// )
/// ```
///
/// \@see\@aes,\@geom-point,\@coord-cartesian,\@facet-wrap,\@theme-grey,\@labs
#let plot(
  data: none,
  mapping: none,
  layers: (),
  scales: (),
  coord: none,
  facet: none,
  theme: none,
  labs: none,
  guides: (:),
  width: 10cm,
  height: 7cm,
  alt: none,
  strict: false,
  defer: false,
) = {
  // Deferred plots skip the context block because `context` returns
  // content; compose() resolves the active theme from its own context
  // before handing the spec to the renderer.
  if defer {
    return (
      data: _normalise-data(data),
      mapping: mapping,
      layers: layers,
      scales: scales,
      coord: coord,
      facet: facet,
      theme: theme,
      labs: labs,
      guides: guides,
      width: width,
      height: height,
      alt: alt,
      strict: strict,
    )
  }
  context {
    let spec = (
      data: _normalise-data(data),
      mapping: mapping,
      layers: layers,
      scales: scales,
      coord: coord,
      facet: facet,
      theme: theme,
      labs: labs,
      guides: guides,
      width: width,
      height: height,
      alt: alt,
      strict: strict,
    )
    let rendered = render-plot(spec)
    if alt != none {
      figure(
        pdf.artifact(rendered),
        alt: alt,
        kind: "gribouille-plot",
        supplement: none,
        numbering: none,
        caption: none,
      )
    } else {
      rendered
    }
  }
}

/// Read the alt text stored on a plot spec.
///
/// Returns whatever was passed to\@plot via `alt:`, or `none` if the
/// spec was built without one. This lets renderers and accessibility
/// tooling pull the description out without parsing the rendered
/// figure.
///
/// \@category Helpers
/// \@stability stable
/// \@since 0.0.1
///
/// \@param plot Plot spec dictionary (the dict\@plot builds internally).
///
/// \@returns The alt string, or `none` if absent.
///
/// \@examples-static Pull the alt text from a built spec for accessibility
/// reporting.
/// ```
/// #let p = (data: (), alt: "Scatter of weight vs mpg")
/// #let alt = get-alt-text(p)
/// ```
#let get-alt-text(plot) = plot.at("alt", default: none)
