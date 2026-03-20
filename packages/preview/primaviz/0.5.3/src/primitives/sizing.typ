// sizing.typ - Sizing and grid layout utilities

/// Golden ratio for aspect-ratio calculations
#let _phi = 1.618

/// Resolves width and height to absolute lengths using the available region size.
/// Call inside `layout(size => ...)`. Handles auto, ratio (100%), relative (100% - 5pt),
/// and absolute (300pt) values.
///
/// When width or height is `auto`, computes natural dimensions from data count
/// and theme using: `width = n × cell-size + padding`, `height = width / φ`.
/// Pass `n` (data point count) and `theme` to enable auto-sizing.
///
/// When `container: true` (the default), reserves space for chart-container's
/// inset padding so charts don't overflow their grid cells. Set `container: false`
/// for charts that render into a plain box without chart-container.
///
/// - width (auto, length, ratio, relative): Width to resolve
/// - height (auto, length, ratio, relative): Height to resolve
/// - size (dictionary): Available region from `layout(size => ...)`
/// - n (none, int): Number of data categories (for auto-sizing)
/// - theme (none, dictionary): Resolved theme (for auto-sizing)
/// - container (bool): Whether to reserve space for chart-container inset
/// -> dictionary with `width` and `height` keys
#let resolve-size(width, height, size, n: none, theme: none, container: true) = {
  import "../primitives/container.typ": container-inset
  let ci = if theme != none { theme.at("container-inset", default: container-inset) } else { container-inset }
  let margin = if container { 2 * ci } else { 0pt }

  // Compute natural width from data count + theme
  let natural-w = if n != none and theme != none {
    let cs = theme.at("cell-size", default: 25pt)
    let pl = theme.at("axis-padding-left", default: 41pt)
    let pr = theme.at("axis-padding-right", default: 16pt)
    n * cs + pl + pr
  } else { 300pt }

  // Natural height = golden-ratio proportion of width
  let natural-h = natural-w / _phi

  let resolve(val, avail, natural) = {
    let resolved = if val == auto { natural }
      else if type(val) == length { val }
      else if type(val) == ratio { avail * (val / 100%) }
      else if type(val) == relative { val.length + avail * (val.ratio / 100%) }
      else { val }
    // Clamp to available space so charts don't overflow containers.
    if type(resolved) == length and type(avail) == length and avail > 0pt {
      calc.min(resolved, avail - margin)
    } else {
      resolved
    }
  }
  (width: resolve(width, size.width, natural-w), height: resolve(height, size.height, natural-h))
}

/// Lays out items in a paged grid with automatic pagebreaks.
///
/// Groups items into pages of `cols * rows`, rendering each page as a grid
/// and inserting `#pagebreak()` between pages.
///
/// - items (array): Array of content items (charts, blocks, etc.)
/// - cols (int): Number of columns per page
/// - rows (int): Number of rows per page
/// - col-gutter (length): Horizontal gap between columns
/// - row-gutter (length): Vertical gap between rows
/// -> content
#let page-grid(items, cols: 2, rows: 4, col-gutter: 8pt, row-gutter: 4pt) = {
  let per-page = cols * rows
  let pages = calc.ceil(items.len() / per-page)
  for p in array.range(pages) {
    if p > 0 { pagebreak() }
    let start = p * per-page
    let end = calc.min(start + per-page, items.len())
    let page-items = items.slice(start, end)
    grid(
      columns: array.range(cols).map(_ => 1fr),
      column-gutter: col-gutter,
      row-gutter: row-gutter,
      ..page-items,
    )
  }
}
