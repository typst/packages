// radial.typ - Frame helpers shared by the radial charts
//
// What every radial chart sets up around its circle: a side legend sized to
// its entries, a width budget, a title scaled to the chart.

#import "../theme.typ": get-color
#import "legend.typ": draw-legend-vertical
#import "container.typ": container-inset

/// A vertical legend sized to its entries, placed beside the chart by
/// `chart-container`. Returns `(legend, width, height, theme)`: pass `legend`
/// and `width` as the container's `legend` and `legend-width`, and `theme` (with
/// `legend-position` set to `position`). The container grows to a legend taller
/// than the chart; `height` is for charts that want to know.
///
/// A legend taller than `max-height` flows into several columns (down each
/// column, then across), as few as hold it, balanced, and no more than
/// `max-total` of width allows; what still does not fit makes a taller
/// legend, and the container grows to hold it. With `max-height`
/// left `auto` the legend is always one column. The result also has `cols`,
/// the number of columns.
///
/// - entries (array): Strings, or dictionaries with `name` (and `color`)
/// - theme (dictionary): Resolved theme
/// - enabled (bool): False yields no legend
/// - min-width (length): Narrowest a legend column may be
/// - max-width (length): Widest a legend column may be
/// - position (str): `"right"` or `"left"`
/// - max-height (auto, length): Tallest a column should get before the legend flows into another one (the chart's height)
/// - max-total (auto, length): Widest the whole legend may get with several columns (see `legend-room`)
/// -> dictionary
#let side-legend(entries, theme, enabled: true, min-width: 60pt, max-width: 180pt, position: "right", max-height: auto, max-total: auto) = {
  if not enabled or entries.len() == 0 {
    (legend: none, width: 0pt, height: 0pt, theme: theme, cols: 0)
  } else {
    let names = entries.map(e => if type(e) == dictionary and "name" in e { e.name } else { e })
    let widest = calc.max(..names.map(n => measure(text(size: theme.legend-size)[#n]).width))
    let w = calc.max(min-width, calc.min(max-width, widest + theme.legend-swatch-size + 5pt))
    let legend = draw-legend-vertical(entries, theme, width: w)
    let themed = theme
    themed.insert("legend-position", position)
    let measured(c) = measure(c).height
    let (n, gutter) = (entries.len(), 10pt)
    let h1 = measured(legend)
    // Columns: as many as the height asks for, as many as the width allows
    let cols = if max-height == auto or max-height <= 0pt or h1 <= max-height { 1 } else {
      let want = calc.min(n, 6, calc.ceil(h1 / max-height))
      let room = if max-total == auto { want } else { calc.max(1, calc.floor((max-total + gutter) / (w + gutter))) }
      calc.min(want, room)
    }
    if cols > 1 {
      // Balanced columns, with their colours fixed first so a column that
      // starts mid-list does not start over in the palette
      let rows = calc.ceil(n / cols)
      let fixed = entries.enumerate().map(((i, e)) => if type(e) == dictionary and "color" in e { e } else {
        (name: if type(e) == dictionary and "name" in e { e.name } else { e }, color: get-color(theme, i))
      })
      let chunks = range(0, n, step: rows).map(i => fixed.slice(i, calc.min(i + rows, n)))
      let flow = grid(columns: (w,) * chunks.len(), column-gutter: gutter, ..chunks.map(c => draw-legend-vertical(c, theme, width: w)))
      (legend: flow, width: chunks.len() * w + (chunks.len() - 1) * gutter, height: measured(flow), theme: themed, cols: chunks.len())
    } else {
      (legend: legend, width: w, height: h1, theme: themed, cols: 1)
    }
  }
}

/// Width a side legend of several columns may take: what the container has,
/// less the chart at 70% of its wanted size (it shrinks that much before a
/// taller legend is preferred), the labels around it and the gap between
/// them. `auto` for an unbounded region. Pass it as `side-legend`'s
/// `max-total`; check the result against the chart once its labels are laid
/// out (`legend-left`).
///
/// - size (length): Wanted chart width
/// - avail-w (length): Width of the containing region
/// - theme (dictionary): Resolved theme (for the container's inset)
/// - margin (length): Width the chart's labels take on both sides together
/// -> auto, length
#let legend-room(size, avail-w, theme, margin: 40pt) = {
  if type(avail-w) != length or avail-w <= 0pt or avail-w > 4000pt { auto }
  else { calc.max(0pt, avail-w - 2 * theme.at("container-inset", default: container-inset) - 0.7 * size - margin - 10pt) }
}

/// What is left of the container's width for a side legend once the chart
/// body (circle and its labels) has its final width: pass it as `max-total`
/// to rebuild a legend that came out too wide. `auto` for an unbounded
/// region.
///
/// - body-w (length): Width of the chart body, labels included
/// - avail-w (length): Width of the containing region
/// - theme (dictionary): Resolved theme (for the container's inset)
/// -> auto, length
#let legend-left(body-w, avail-w, theme) = {
  if type(avail-w) != length or avail-w <= 0pt or avail-w > 4000pt { auto }
  else { calc.max(0pt, avail-w - 2 * theme.at("container-inset", default: container-inset) - body-w - 10pt) }
}

/// Splits the available width between a chart and what sits beside it
/// (legend column, label margins) so both stay inside the container.
/// The chart shrinks first, down to `floor`; below that the side shrinks too.
/// Returns `(chart-size, side-width)`.
///
/// - size (length): Wanted chart width
/// - side (length): Wanted width of everything beside the chart
/// - avail-w (length): Width of the containing region
/// - theme (dictionary): Resolved theme (for the container's inset)
/// - floor (length): Smallest chart worth drawing before the side gives way
/// -> array
#let split-width(size, side, avail-w, theme, floor: 80pt) = {
  if type(avail-w) != length or avail-w <= 0pt { return (size, side) }
  let budget = avail-w - 2 * theme.at("container-inset", default: container-inset)
  if size + side <= budget { (size, side) }
  else if side == 0pt { (calc.max(budget, 20pt), 0pt) }
  else if budget - side >= floor { (budget - side, side) }
  else { (budget * 0.55, budget * 0.45) }
}

/// The theme with its title scaled to a small chart: a full-size bold title
/// over an 80pt dial shouts over the heading of the group the dial sits in.
/// Charts of 130pt and more keep the theme's title size.
///
/// - theme (dictionary): Resolved theme
/// - chart-size (length): The chart's diameter or width
/// -> dictionary
#let title-for-size(theme, chart-size) = {
  let s = calc.max(theme.axis-label-size, calc.min(theme.title-size, chart-size * 0.1))
  if s >= theme.title-size { theme } else {
    let scaled = theme
    scaled.insert("title-size", s)
    scaled
  }
}
