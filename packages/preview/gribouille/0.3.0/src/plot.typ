#import "render.typ": render-plot
#import "data.typ": _normalise-data
#import "utils/errors.typ": fail

// Effective alt text: an explicit `plot(alt:)` wins; otherwise a `labs(alt:)`
// fills in (its `auto` default and `none` both count as unset), so the labs
// field reaches `get-alt-text` instead of being dropped.
#let _resolve-alt(alt, labs) = {
  if alt != none { return alt }
  if labs != none {
    let labs-alt = labs.at("alt", default: auto)
    if labs-alt != auto and labs-alt != none { return labs-alt }
  }
  none
}

/// Compose a layered plot from data, aesthetics, and geom layers.
///
/// `plot` is the entry point of the grammar: it resolves the dataset, wires up the aesthetic mapping, trains scales against the data, applies coordinate, facet, theme, and label choices, and dispatches to the internal renderer. Call it once per figure, passing the layers you want to stack.
///
/// - data: Either an array of row dictionaries (one row per observation, e.g., `((x: 1, y: 2), (x: 3, y: 4))`) or a dictionary of equal-length column arrays (e.g., `(x: (1, 3), y: (2, 4))`). Column-store input is normalised to row-store internally.
/// - mapping: Aesthetic mapping built with`aes`. Maps column names to visual channels.
/// - layers: Array of geom layers (e.g., `geom-point`,`geom-line`). Drawn in order.
/// - scales: Array of scale objects overriding defaults `scale-x-continuous`,`scale-colour-viridis-d`, etc.).
/// - coord: Coordinate system. Defaults to`coord-cartesian` when `none`.
/// - facet: Faceting specification built with`facet-wrap` or`facet-grid`.
/// - theme: Theme object (e.g., `theme-grey`,`theme-minimal`,`theme-classic`). Controls non-data ink.
/// - labs: Labels dictionary built with`labs` (title, subtitle, caption, axis titles).
/// - guides: Per-aesthetic guide overrides built with`guides` (e.g., `guides(colour: guide-legend(reverse: true))`).
/// - width: Total image width, including axes, legends, title, subtitle, caption, and plot-background padding. The data panel shrinks to leave room for chrome; long titles wrap to fit. Chrome larger than `width` raises an error. Pass `auto` to fill the available width of the container the plot sits in (resolved through Typst `layout`); when that container is unbounded (e.g., an auto-width page) it falls back to `10cm`. Inside`compose` the panel's own width is discarded; the composition sizes each cell.
/// - height: Total image height, including axes, legends, title, subtitle, caption, and plot-background padding. The data panel shrinks to leave room for chrome. Chrome larger than `height` raises an error. Pass `auto` to fill the available height of the container (resolved through Typst `layout`); most predictable inside a fixed-height container such as a `box` or `block` with a set height, and falls back to `7cm` when the container is unbounded. Inside`compose` the panel's own height is discarded; the composition sizes each cell.
/// - alt: Alt text describing the figure. When set, the rendered plot is wrapped in a `figure` (kind `"gribouille-plot"`, no number, no caption) carrying this string as its PDF alternative text, so a screen reader on a tagged PDF announces the description instead of the raw axis and legend labels. When `none`, the plot renders without the figure wrapper. Quarto authors embedding plots through `typst-render` should set the block-level `alt` cell option for HTML output; this parameter only affects direct Typst compilation.
/// - strict: When `true`, panic on the first row whose value falls outside any user-supplied scale `limits`. Default `false` drops such rows silently. Use in docs and CI to surface mismatched limits rather than producing thinned-out plots.
/// - as-spec: Internal switch driven by`defer`: when `true`, return the spec dict instead of rendering, so`compose` can probe guides and re-render with hoisted aesthetics suppressed. Use`defer` rather than setting this directly; the dict carries the same keys the renderer would consume and must not be fed to anything other than`compose`.
///
/// Returns: Typst content block containing the rendered figure, or the spec dict when `as-spec: true`.
///
/// See also: `aes`, `geom-point`, `coord-cartesian`, `facet-wrap`, `theme-grey`, `labs`.
///
/// Single-layer scatter coloured by category, with a title.
///
/// ```typst
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
/// Stack two layers (`geom-point` + `geom-smooth`) and apply a theme, scales, and facets in one call.
///
/// ```typst
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
  as-spec: false,
) = {
  let alt = _resolve-alt(alt, labs)
  // Deferred plots skip the context block because `context` returns
  // content; compose() resolves the active theme from its own context
  // before handing the spec to the renderer.
  if as-spec {
    if width == auto or height == auto {
      fail(
        "plot",
        "`auto` width/height cannot be deferred to compose()",
        hint: "A deferred panel needs concrete dimensions to probe its guides.",
      )
    }
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
  layout(size => context {
    // `auto` fills the container; when the container is unbounded (e.g., a
    // `width: auto` page) there is no size to take, so fall back to the same
    // default dimensions the signature uses.
    let resolved-width = if width != auto {
      width
    } else if size.width.pt() < float.inf {
      size.width
    } else { 10cm }
    let resolved-height = if height != auto {
      height
    } else if size.height.pt() < float.inf {
      size.height
    } else { 7cm }
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
      width: resolved-width,
      height: resolved-height,
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
  })
}

/// Read the alt text stored on a plot spec.
///
/// Returns whatever was passed to`plot` via `alt:`, or `none` if the spec was built without one. This lets renderers and accessibility tooling pull the description out without parsing the rendered figure.
///
/// - plot: Plot spec dictionary (the dict`plot` builds internally).
///
/// Returns: The alt string, or `none` if absent.
///
/// Pull the alt text from a built spec for accessibility reporting.
///
/// ```typst
/// #let p = (data: (), alt: "Scatter of weight vs mpg")
/// #let alt = get-alt-text(p)
/// ```
#let get-alt-text(plot) = plot.at("alt", default: none)
