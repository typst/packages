// Measure text at natural size before allocating the figure. Rendering panels
// consume this geometry without measuring again, so every shared edge agrees.
#import "text.typ": _as-content
#import "change-display.typ": changed-label, row-status, column-status

#let figure-layout(data, style, cell-size, row-height, what-width, importance-width,
  comparison-width, header-height, basement-height, legend-width, legend-gap,
  cell-padding, label-padding, header-padding, legend-size) = {
  for value in (cell-size, what-width, importance-width, comparison-width,
    legend-width, style.font-size, style.symbol-size, style.grid-thickness, style.frame-thickness) {
    assert(type(value) == length and value > 0pt, message: "qfd: dimensions and thicknesses must be positive lengths")
  }
  for value in (cell-padding, label-padding, header-padding, legend-gap) {
    assert(type(value) == length and value >= 0pt, message: "qfd: padding and gaps must be nonnegative lengths")
  }
  assert(what-width > 2 * label-padding, message: "qfd: label padding leaves no room for text")
  let direction-height = if data.directions.any(d => d != none and d != "none") { 5mm } else { 0pt }
  let header-height = if header-height == auto {
    calc.max(12mm, ..data.hows.enumerate().map(((c, label)) => measure(box(changed-label(label, column-status(data, c)))).width + 2 * header-padding)) + direction-height
  } else { header-height }
  let row-height = if row-height == auto {
    calc.max(style.symbol-size + 2 * cell-padding, 7mm,
      ..data.whats.enumerate().map(((r, label)) => measure(block(width: what-width - 2 * label-padding,
        breakable: false, changed-label(label, row-status(data, r)))).height + 2 * label-padding))
  } else { row-height }
  let basement-height = if basement-height == auto { 7mm } else { basement-height }
  for value in (header-height, row-height, basement-height) {
    assert(type(value) == length and value > 0pt, message: "qfd: resolved dimensions must be positive lengths")
  }
  assert(header-height > direction-height, message: "qfd: header must leave room above direction indicators")
  let pad = calc.max(1.5mm, style.frame-thickness)
  let iw = if data.show-importance { importance-width } else { 0pt }
  let cw = if data.show-competitive { comparison-width } else { 0pt }
  let mx = pad + what-width + iw
  let mw = data.nc * cell-size
  let roof-base = pad + if data.show-roof { mw / 2 } else { 0pt }
  let my = roof-base + header-height
  let mh = data.nr * row-height
  let right-edge = mx + mw + cw
  let legend-x = right-edge + legend-gap
  let canvas-width = if legend-size.width == 0pt { right-edge + pad } else { legend-x + legend-size.width + pad }
  let under-body = calc.max(data.basement.len() * basement-height, if data.show-competitive { 6mm } else { 0pt })
  let canvas-height = calc.max(my + mh + under-body, roof-base + legend-size.height) + pad
  (pad: pad, cell: cell-size, row: row-height, what: what-width, iw: iw, cw: cw,
   header: header-height, basement: basement-height, direction: direction-height,
   mx: mx, mw: mw, my: my, mh: mh, roof-base: roof-base, right: right-edge,
   legend-x: legend-x, width: canvas-width, height: canvas-height,
   cell-padding: cell-padding, label-padding: label-padding, header-padding: header-padding)
}

// Uniform final scaling is explicit: natural width is safe on auto-sized pages;
// a ratio needs a finite layout region. It never silently paginates a matrix.
#let fit-figure(drawing, natural-width, width) = layout(region => {
  let requested = if width == auto { natural-width }
    else if type(width) == length { width }
    else if type(width) == ratio { width * region.width }
    else if type(width) == relative { width.length + width.ratio * region.width }
    else { panic("qfd: width must be auto, a length, a ratio, or a relative length") }
  assert(requested > 0pt and requested < calc.inf * 1pt,
    message: "qfd: width must resolve to a finite positive length; use width: auto on auto-width pages")
  scale(requested / natural-width * 100%, reflow: true, drawing)
})
