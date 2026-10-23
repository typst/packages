// legend.typ - Legend rendering primitives

#import "../theme.typ": *
#import "../util.typ": heat-color
#import "fonts.typ": pin
#import "axes.typ": _clip-label, value-text

/// Side of a legend swatch: the theme's `legend-swatch-size`, never more than
/// three quarters of the legend text (`legend-size`): a swatch is a key to the label
/// beside it and must not dominate it. So the key is configurable, through a theme
/// override (`theme: (legend-swatch-size: 5pt)`) or per legend by passing a theme
/// with the key set (`(..t, legend-swatch-size: 5pt)`, as `dumbbell-chart` does for
/// its dots), but it only makes swatches smaller than that cap, not larger.
///
/// - theme (dictionary): Resolved theme
/// -> length
#let legend-swatch-size(theme) = calc.min(theme.legend-swatch-size, theme.legend-size * 0.75)

// Optional legend title rendered above entries.
#let _legend-title(title, theme) = {
  if title != none {
    text(size: theme.legend-size, weight: "bold", fill: theme.text-color)[#title]
    v(3pt)
  }
}

// One legend entry: a swatch centred on the label's cap height, then the label.
// Swatch and label are one box so an entry never breaks across lines. It is
// built in code mode, with no markup spaces, so its width does not depend on the
// ambient text size (the legend is measured where it is made and drawn elsewhere).
#let _legend-entry(name, color, theme, swatch-type) = {
  let sz = legend-swatch-size(theme)
  // Shift that centres a swatch of height `h` on the label's cap-height band
  let centred(h) = (h - 0.66 * theme.legend-size) / 2
  box({
    if swatch-type == "line" {
      box(width: 1.6 * sz, height: theme.stroke-thick, fill: color, baseline: centred(theme.stroke-thick))
    } else if swatch-type == "circle" {
      box(width: sz, height: sz, baseline: centred(sz),
        circle(radius: sz / 2, fill: color, stroke: theme.marker-stroke))
    } else {
      box(width: sz, height: sz, fill: color, baseline: centred(sz), radius: sz * 0.2)
    }
    h(0.4 * sz)
    text(size: theme.legend-size, fill: theme.text-color)[#name]
  })
}

/// Widest a legend entry may be in a chart `width` wide: the room a side legend
/// is given (40% of the width), or the full width for a legend above or below.
/// Charts pass this as `max-width` to the legend they build.
///
/// - width (length): Chart width
/// - theme (dictionary): Resolved theme
/// -> length
#let legend-max-width(width, theme) = if theme.legend-position == "right" or theme.legend-position == "left" {
  0.4 * width
} else { width }

// The name of an entry as drawn: a string name that would make its entry wider
// than `max-width` is cut and closed with an ellipsis (content names are kept).
#let _entry-name(name, color, theme, swatch-type, max-width) = if max-width == none { name } else {
  _clip-label(name, c => measure(_legend-entry(c, color, theme, swatch-type)).width <= max-width)
}

// Name and color of the i-th legend entry (a string or a dict with name/color).
#let _entry-parts(entry, i, theme) = (
  if type(entry) == dictionary and "name" in entry { entry.name } else { entry },
  if type(entry) == dictionary and "color" in entry { entry.color } else { get-color(theme, i) },
)

// The legends below are laid out at Typst's default type size and leading, whatever
// the document's `set text(size: ..)`: their entries carry their own sizes, and what
// is left (the leading between wrapped rows) must not move with the ambient size, so
// a legend measures the same wherever it is measured.
#let _pinned(content) = { set text(size: 11pt); set par(leading: 0.65em); content }

// Horizontal legend (for bar, line, area charts). Entries flow onto further rows
// when they do not fit side by side; with `max-width`, an entry wider than that is cut.
#let draw-legend(entries, theme, swatch-type: "box", title: none, max-width: none) = {
  v(5pt)
  align(center, _pinned({
    _legend-title(title, theme)
    for (i, entry) in entries.enumerate() {
      // Gaps go between entries, so the row stays centred
      if i > 0 { h(theme.legend-gap) }
      let (name, color) = _entry-parts(entry, i, theme)
      _legend-entry(_entry-name(name, color, theme, swatch-type, max-width), color, theme, swatch-type)
    }
  }))
}

// Vertical legend (for pie, radar, side panels). `width: auto` fits the widest entry;
// with `max-width`, an entry wider than that is cut with an ellipsis.
#let draw-legend-vertical(entries, theme, width: 130pt, title: none, swatch-type: "box", max-width: none) = {
  box(width: width, _pinned({
    _legend-title(title, theme)
    for (i, entry) in entries.enumerate() {
      let (name, color) = _entry-parts(entry, i, theme)
      _legend-entry(_entry-name(name, color, theme, swatch-type, max-width), color, theme, swatch-type)
      if i < entries.len() - 1 {
        linebreak()
        v(2pt)
      }
    }
  }))
}

/// Automatically picks horizontal or vertical legend based on
/// `theme.legend-position`.  Returns `none` when the legend is
/// suppressed (`show-legend` is false or position is `"none"`).
///
/// - entries (array): Legend entries — strings or dicts with `name` (and optional `color`)
/// - theme (dictionary): Resolved theme
/// - show-legend (bool): Master toggle; when false nothing is rendered
/// - swatch-type (str): `"box"`, `"line"`, or `"circle"`
/// - title (none, str): Optional legend title displayed above entries
/// - fit-width (bool): Size a side legend to its widest entry instead of the default column
/// - max-width (none, length): Widest an entry may be (see `legend-max-width`): longer names
///   are cut with an ellipsis, and a horizontal legend wraps onto further rows. `none` leaves
///   entries as long as they are
/// -> content, none
#let draw-legend-auto(entries, theme, show-legend: true, swatch-type: "box", title: none, fit-width: false, max-width: none) = {
  if not show-legend { return }
  if theme.legend-position == "none" { return }
  if entries.len() == 0 { return }

  if theme.legend-position == "right" or theme.legend-position == "left" {
    draw-legend-vertical(entries, theme, title: title, swatch-type: swatch-type, max-width: max-width, ..if fit-width { (width: auto) })
  } else {
    draw-legend(entries, theme, swatch-type: swatch-type, title: title, max-width: max-width)
  }
}

// The end labels of a gradient legend, their type size and the width the legend
// takes. Numbers print to one decimal, large ones in the compact form of tick labels
// (`1.5B`); a label wider than the bar and its margin shrinks (to 5pt at most), and
// when even that does not fit the legend is as wide as its widest label.
#let _gradient-parts(min-val, max-val, theme, bar-width) = {
  let label(v) = if (type(v) == int or type(v) == float) and calc.abs(v) >= 10000 { value-text(v, theme) }
    else if type(v) == int or type(v) == float { calc.round(v, digits: 1) } else { v }
  let (hi, lo) = (label(max-val), label(min-val))
  let widest(sz) = calc.max(measure(text(size: sz)[#hi]).width, measure(text(size: sz)[#lo]).width)
  let room = bar-width + 8pt
  let sz = theme.axis-label-size
  let w = widest(sz)
  let sz = if w <= room { sz } else { calc.max(5pt, sz * (room / w)) }
  (hi: hi, lo: lo, size: sz, width: calc.max(room, widest(sz)),
   w-hi: measure(text(size: sz)[#hi]).width, w-lo: measure(text(size: sz)[#lo]).width)
}

/// Width of `draw-gradient-legend`: the bar and its margin, wider when the end labels
/// of a large or long number need it. For charts that reserve room for the legend.
///
/// - min-val (number): Minimum data value
/// - max-val (number): Maximum data value
/// - theme (dictionary): Resolved theme
/// - bar-width (length): Width of the gradient bar
/// -> length
#let gradient-legend-width(min-val, max-val, theme, bar-width: 15pt) = _gradient-parts(min-val, max-val, theme, bar-width).width

/// Gradient color bar legend for heatmaps and color-mapped charts.
///
/// Renders a vertical gradient bar with min/max labels. Can be placed
/// inline or absolutely positioned by the caller. The labels stay inside the
/// legend's width (`gradient-legend-width`): numbers of 10 000 and more are
/// shortened (`1.5B`), and a label wider than the bar shrinks to fit.
///
/// - min-val (number): Minimum data value (label at bottom)
/// - max-val (number): Maximum data value (label at top)
/// - palette (str, array): Palette name or color stop array
/// - theme (dictionary): Resolved theme
/// - bar-width (length): Width of the gradient bar
/// - bar-height (length): Height of the gradient bar
/// - steps (int): Number of discrete color segments
/// - reverse (bool): Reverse palette direction
/// -> content
#let draw-gradient-legend(min-val, max-val, palette, theme, bar-width: 15pt, bar-height: auto, steps: 30, reverse: false) = {
  let h = if bar-height == auto { 80pt } else { bar-height }
  let step-h = h / steps
  let g = _gradient-parts(min-val, max-val, theme, bar-width)
  // A label is centred on the bar, or starts at the legend's edge when it is wider
  let at(w) = calc.max(0pt, calc.min(bar-width / 2 - w / 2, g.width - w))
  box(width: g.width, height: h + 4pt)[
    // Gradient bar
    #for i in array.range(steps) {
      let normalized = 1 - i / steps
      let cell-color = heat-color(normalized, palette: palette, reverse: reverse)
      place(left + top,
        dx: 0pt,
        dy: (i / steps) * h,
        rect(width: bar-width, height: step-h + 0.5pt, fill: cell-color, stroke: none))
    }
    // Max label (above bar)
    #place(left + top, dx: at(g.w-hi), dy: -2pt,
      pin(width: g.w-hi, align: left + bottom, text(size: g.size, fill: theme.text-color)[#g.hi]))
    // Min label (below bar)
    #place(left + top, dx: at(g.w-lo), dy: h + 2pt,
      box(width: g.w-lo, text(size: g.size, fill: theme.text-color)[#g.lo]))
  ]
}

/// Size legend for bubble charts — shows 2-3 reference circles with labels.
///
/// - sizes (array): Array of (value, label) pairs for reference bubbles
/// - max-radius (length): Maximum bubble radius (for scaling)
/// - max-value (number): Maximum data value (for scaling)
/// - theme (dictionary): Resolved theme
/// - title (none, str): Optional title (e.g., "Market Value (£M)")
/// - max-legend-radius (length): Largest reference circle drawn, so a chart with big bubbles does not get a big legend
/// -> content
#let draw-size-legend(sizes, max-radius, max-value, theme, title: none, max-legend-radius: 12pt) = {
  let cap = calc.min(max-radius, max-legend-radius)
  // One reference circle and its label, a single box (code mode: its width does
  // not depend on the ambient text size)
  let entry(val, lbl) = box({
    let r = calc.max(2pt, cap * calc.sqrt(val / calc.max(1, max-value)))
    box(baseline: r - 1pt, box(width: 2 * r, height: 2 * r,
      circle(radius: r, fill: none, stroke: theme.text-color-light + 0.75pt)))
    h(2pt)
    text(size: theme.legend-size, fill: theme.text-color)[#lbl]
  })
  if theme.legend-position == "right" or theme.legend-position == "left" {
    // Beside the chart: a column, like the series legend
    box(_pinned({
      _legend-title(title, theme)
      for (i, (val, lbl)) in sizes.enumerate() {
        entry(val, lbl)
        if i < sizes.len() - 1 { linebreak(); v(2pt) }
      }
    }))
  } else {
    v(3pt)
    align(center, _pinned({
      if title != none {
        text(size: theme.legend-size, fill: theme.text-color)[#title]
        h(6pt)
      }
      for (i, (val, lbl)) in sizes.enumerate() {
        if i > 0 { h(8pt) }
        entry(val, lbl)
      }
    }))
  }
}
