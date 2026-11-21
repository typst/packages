///! keisen nanoplot renderer built from the parts of a Gribouille plot.
///!
///! keisen takes a renderer as a dictionary `(kind: "nanoplot-renderer", draw,
///! readings, axis)` and never imports Gribouille, and nothing here imports
///! keisen: the two meet only through that dictionary. keisen reads every cell
///! of a column with `readings`, computes one domain for the column, then calls
///! `draw` for each cell and `axis` for the column axis with that domain.

#import "../plot.typ": plot
#import "../aes.typ": aes
#import "../guides.typ": guides
#import "../labels.typ": labels
#import "../coord/cartesian.typ": coord-cartesian
#import "../geom/blank.typ": geom-blank
#import "../scale/continuous.typ": _continuous-scale
#import "../scale/expansion.typ": normalise-expansion
#import "../scale/secondary.typ": dup-axis
#import "../theme/void.typ": theme-void
#import "../theme/theme.typ": (
  _normalise-margin, _text-style, _tick-length, resolve-element,
)
#import "../theme/elements.typ": (
  element-blank, element-rect, element-text, margin,
)
#import "../utils/errors.typ": fail-enum, fail-type

#let _SIDES = ("top", "bottom")

// The surfaces of the panel, blanked on the axis so it draws ticks and labels
// only. Each per-axis key is set as well, because a key a user theme sets below
// `panel-grid` wins over a blank set on `panel-grid` itself.
#let _PANEL-SURFACES = (
  "panel-background",
  "panel-grid",
  "panel-grid-major",
  "panel-grid-minor",
  "panel-grid-major-x",
  "panel-grid-major-y",
  "panel-grid-minor-x",
  "panel-grid-minor-y",
)

// A cell holds an array of records; anything else holds no readings. A value
// that is not a finite number is no reading either, since keisen takes the
// minimum and the maximum of every reading for the column domain.
#let _readings(value, field) = {
  if type(value) != array { return () }
  value
    .filter(record => type(record) == dictionary)
    .map(record => record.at(field, default: none))
    .filter(reading => type(reading) in (int, float, decimal))
    .map(float)
    .filter(reading => (
      not float.is-nan(reading) and not float.is-infinite(reading)
    ))
}

// The x scale the cells and the axis share: the user's scale, expansion
// included.
#let _x-scale(scales) = scales.at("x", default: _continuous-scale("x"))

// The coordinate system the cells and the axis share. The column domain is set
// as `x-limits` and not as scale limits, because a geom that draws whole marks
// widens a scale past its limits, and each cell would then widen its own scale.
#let _coord(domain) = if domain == none { none } else {
  coord-cartesian(x-limits: (domain.first(), domain.last()))
}

// The axis is drawn on a canvas `pad` wider on each side, with `pad` added to
// the expansion, so its data area is the cells' data area moved right by `pad`.
// A label at the end of the domain then sits inside the canvas, and Gribouille
// keeps no margin for it that would narrow the data area.
#let _axis-scale(x, pad, side) = {
  let (mult-lo, add-lo, mult-hi, add-hi) = normalise-expansion(
    x.at("expand", default: auto),
    "continuous",
  )
  x.insert("expand", (
    mult-lo * 100% + add-lo * 1cm + pad,
    mult-hi * 100% + add-hi * 1cm + pad,
  ))
  // A top axis is the bottom one copied to the top edge, with the same breaks
  // and labels.
  x.insert("secondary", if side == "top" {
    dup-axis(
      breaks: x.at("breaks", default: auto),
      labels: x.at("labels", default: auto),
    )
  } else { none })
  x
}

// A ratio side of a margin resolves against the plot canvas, which is wider on
// the axis than in a cell, so a left or right side is given at the cell width.
#let _at-width(value, width) = if type(value) == ratio {
  value * width
} else if type(value) == relative {
  value.ratio * width + value.length
} else { value }

// The axis theme: the cell theme with no panel, nothing on the other side, and
// labels on the asked side even when the theme hides them, as theme-void does.
// The canvas reaches `pad` past the column on each side, so the axis lines and
// the plot background, which span the whole canvas, are not drawn.
// The plot padding stays on the left and right, where the cells have it too,
// and goes from the top and bottom, which would take the axis height.
#let _axis-theme(base, side, width) = {
  let other = if side == "top" { "bottom" } else { "top" }
  let out = base
  for key in _PANEL-SURFACES { out.insert(key, element-blank()) }
  let background = resolve-element(out, "plot-background")
  if background.at("kind", default: none) == "element-rect" {
    // A `none` field inherits from `rect`, so the record keeps the padding
    // only, and `rect` is blank so it gives no paint.
    let inset = _normalise-margin(background.at("inset", default: none))
    let outset = _normalise-margin(background.at("outset", default: none))
    out.insert("rect", element-blank())
    out.insert("plot-background", element-rect(
      inset: margin(
        top: 0pt,
        right: _at-width(inset.right, width),
        bottom: 0pt,
        left: _at-width(inset.left, width),
      ),
      outset: margin(
        top: outset.top,
        right: _at-width(outset.right, width),
        bottom: outset.bottom,
        left: _at-width(outset.left, width),
      ),
    ))
  }
  for family in ("axis-text", "axis-ticks") {
    out.insert(family + "-x-" + other, element-blank())
  }
  for edge in ("x-top", "x-bottom", "y-left", "y-right") {
    out.insert("axis-line-" + edge, element-blank())
  }
  let text-key = "axis-text-x-" + side
  if (
    resolve-element(out, text-key).at("kind", default: none) == "element-blank"
  ) {
    out.insert(text-key, element-text())
  }
  out
}

// The height the axis needs: its tick, and a line of its label text.
#let _auto-axis-height(axis-theme, side) = {
  let label = _text-style(axis-theme, "axis-text-x-" + side).size
  _tick-length(axis-theme, "axis-ticks-x-" + side) + 1.4 * label
}

/// Draw a Gribouille plot in each cell of a keisen nanoplot column, with a shared axis.
///
/// `nanoplot` returns a keisen nanoplot renderer. Give it to the `plot` argument of keisen's `format-nanoplot`. Each cell holds an array of records, and the cell draws them as the `data` of `plot`, with the given `mapping`, `layers`, `scales` and `theme`.
///
/// keisen reads the `domain-field` of every record in the column and computes one domain. Each cell then uses that domain as the `limits` of its x scale, so all cells share one x scale. The other arguments of the x scale in `scales` stay as given. The x scale keeps the default expansion of Gribouille unless the x scale in `scales` sets `expand`. Cells draw no axes, no axis titles and no legends.
///
/// When `axis` is `true`, keisen draws the x axis of the column below the column labels and again after the last row. The axis uses the same x scale and theme as the cells, so each break lines up with the cells. The cells and the axis set the column domain as the `x-limits` of `coord-cartesian`, so a geom that draws whole marks, such as `geom-col`, `geom-tile` or `geom-histogram`, does not widen the scale of a cell. A mark at the end of the domain is centred on the end, and the part of it past the end is drawn into the cell margin. To draw whole marks, give keisen's `format-nanoplot` a `domain` that holds them, for example half a bar width past each end, as in `domain: (-0.5, 10.5)` for bars at 0 to 10. A tick label at the end of the domain is centred on the end, so half of it can go past the column content into the cell inset. It draws the tick labels even when the theme hides them, as `theme-void` does. The axis draws no axis line and no plot background, even when the theme sets them. Gribouille does not import keisen: the renderer is a plain dictionary.
///
/// *Experimental.*
///
/// - mapping: Aesthetic mapping from `aes`, applied to the records of each cell.
/// - layers: Array of geom layers drawn in each cell.
/// - scales: Scales from `scales`. The x scale gets the column domain as its `limits`. It must be continuous, because the column domain is numeric.
/// - theme: Theme for the cells and the axis; `none` (default) uses `theme-void`.
/// - domain-field: Name of the record field that holds the x values, as a string. keisen reads it to compute the column domain. It has no default: `none` fails.
/// - axis: `true` (default) gives the column an x axis; `false` gives it none.
/// - axis-height: Height of the axis, as a length; default `auto`. `auto` gives the height of the axis ticks plus 1.4 times the size of the axis text of the theme. The axis text takes its size from the theme, not from the table, so give a length only to set the height yourself.
///
/// Returns: A keisen nanoplot renderer, `(kind: "nanoplot-renderer", draw, readings, axis)`.
///
/// See also: `plot`, `scales`, `theme-void`.
///
/// Call the drawers of the renderer as keisen does, for one cell and the axis below it.
///
/// ```typst
/// #let renderer = nanoplot(
///   mapping: aes(x: "salary", y: "y"),
///   layers: (geom-point(size: 2pt),),
///   domain-field: "salary",
/// )
/// #let cell = (25000, 32000, 41000, 50000, 58000).map(v => (salary: v, y: 0))
/// #let domain = (20000, 60000)
/// // The end labels reach past the cell, as they reach into the cell inset in a table.
/// #pad(x: 2em, stack(
///   spacing: 2pt,
///   (renderer.draw)(cell, domain: domain, width: 9cm, height: 0.6cm),
///   (renderer.axis)(domain: domain, width: 9cm, side: "bottom"),
/// ))
/// ```
///
/// Draw a strip of salaries in each row of a keisen table, with the axis above the first row and below the last. The document imports keisen as `keisen`.
///
/// ```typst
/// #let rows = (
///   (field: "Engineering", majors: ((salary: 61000, y: 0), (salary: 72000, y: 0))),
///   (field: "Education", majors: ((salary: 38000, y: 0), (salary: 41000, y: 0))),
/// )
/// #keisen.display-table(
///   rows,
///   keisen.format-nanoplot(
///     "majors",
///     plot: nanoplot(
///       mapping: aes(x: "salary", y: "y"),
///       layers: (geom-point(size: 2pt),),
///       scales: scales(x: scale-continuous(labels: format-currency())),
///       domain-field: "salary",
///     ),
///     width: 6cm,
///     height: 0.6cm,
///     domain: (0, 115000),
///   ),
/// )
/// ```
#let nanoplot(
  mapping: none,
  layers: (),
  scales: (:),
  theme: none,
  domain-field: none,
  axis: true,
  axis-height: auto,
) = {
  if type(domain-field) != str {
    fail-type(
      "nanoplot",
      "domain-field",
      domain-field,
      "a field name",
      hint: "Name the record field that holds the x values, as in domain-field: \"salary\".",
    )
  }
  if type(scales) != dictionary {
    fail-type(
      "nanoplot",
      "scales",
      scales,
      "a dictionary from scales()",
      hint: "Build it with scales(x: scale-continuous(...)).",
    )
  }
  let x-type = scales.at("x", default: (:)).at("type", default: "continuous")
  if x-type != "continuous" {
    fail-type(
      "nanoplot",
      "scales.x",
      x-type,
      "a continuous scale",
      hint: "The column domain is numeric. Use scale-continuous() for x.",
    )
  }
  if type(axis) != bool {
    fail-type("nanoplot", "axis", axis, "a boolean")
  }
  if axis-height != auto and type(axis-height) != length {
    fail-type(
      "nanoplot",
      "axis-height",
      axis-height,
      "auto or a length",
      hint: "Give it in em or pt, as in 1.4em.",
    )
  }
  if theme != none and type(theme) != dictionary {
    fail-type(
      "nanoplot",
      "theme",
      theme,
      "a theme dictionary",
      hint: "Call the preset, as in theme: theme-bw().",
    )
  }
  let cell-theme = if theme == none { theme-void() } else { theme }

  // keisen gives em sizes, and a plot takes absolute ones, so the drawers
  // resolve them in context.
  let draw(value, domain: none, width: 4em, height: 0.8em) = context plot(
    data: value,
    mapping: mapping,
    layers: layers,
    scales: scales + (x: _x-scale(scales)),
    coord: _coord(domain),
    theme: cell-theme,
    labels: labels(x: none, y: none),
    guides: guides(default: none, x: none, y: none),
    width: width.to-absolute(),
    height: height.to-absolute(),
  )

  let draw-axis(domain: none, width: 4em, side: "bottom") = {
    if side not in _SIDES { fail-enum("nanoplot", "side", side, _SIDES) }
    if domain == none { return none }
    context {
      let width = width.to-absolute()
      let axis-theme = _axis-theme(cell-theme, side, width)
      let height = if axis-height == auto {
        _auto-axis-height(axis-theme, side)
      } else { axis-height.to-absolute() }
      // Wider than half of any tick label, so no label reaches past the canvas.
      let pad = width + 4cm
      box(width: width, height: height, place(top + left, dx: -pad, plot(
        data: ((x: domain.first(), y: 0), (x: domain.last(), y: 0)),
        mapping: aes(x: "x", y: "y"),
        layers: (geom-blank(),),
        scales: (x: _axis-scale(_x-scale(scales), pad, side)),
        coord: _coord(domain),
        theme: axis-theme,
        labels: labels(x: none, y: none),
        guides: guides(default: none, y: none),
        width: width + 2 * pad,
        height: height,
      )))
    }
  }

  (
    kind: "nanoplot-renderer",
    draw: draw,
    readings: value => _readings(value, domain-field),
    axis: if axis { draw-axis } else { none },
  )
}
