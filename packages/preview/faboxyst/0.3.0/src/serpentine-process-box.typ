// One reusable interlocking node adapted from PresentationGO's Boxes & Serpentine Process.
#import "theme.typ": theme-state
#import "fabox.typ": is-rtl

#let _spb-cubic(p0, p1, p2, p3, n: 16) = range(1, n + 1).map(i => {
  let t = i / n
  let u = 1 - t
  (
    u * u * u * p0.at(0) + 3 * u * u * t * p1.at(0)
      + 3 * u * t * t * p2.at(0) + t * t * t * p3.at(0),
    u * u * u * p0.at(1) + 3 * u * u * t * p1.at(1)
      + 3 * u * t * t * p2.at(1) + t * t * t * p3.at(1),
  )
})

#let _spb-piece-points(width, height, rtl: false) = {
  // The source's lower node: a raised round connector, curved shoulders, and
  // a deeply rounded base. Coordinates follow its 21,600-unit custom path.
  let p = ((width * 0.99935, height * 0.43449),)
  p += _spb-cubic(
    (width * 0.99935, height * 0.43449),
    (width * 0.83222, height * 0.43449),
    (width * 0.69671, height * 0.33834),
    (width * 0.69671, height * 0.22003),
  )
  p.push((width * 0.69671, height * 0.14265))
  p += _spb-cubic(
    (width * 0.69671, height * 0.14265),
    (width * 0.69671, height * 0.06440),
    (width * 0.60657, height * -0.00139),
    (width * 0.49606, height * 0.0),
  )
  p += _spb-cubic(
    (width * 0.49606, height * 0.0),
    (width * 0.38880, height * 0.00139),
    (width * 0.30264, height * 0.06342),
    (width * 0.30264, height * 0.13955),
  )
  p.push((width * 0.30264, height * 0.21970))
  p += _spb-cubic(
    (width * 0.30264, height * 0.21970),
    (width * 0.30264, height * 0.33797),
    (width * 0.16708, height * 0.43341),
    (width * 0.0, height * 0.43341),
  )
  p.push((width * 0.0, height * 0.64581))
  p += _spb-cubic(
    (width * 0.0, height * 0.64581),
    (width * 0.0, height * 0.84131),
    (width * 0.22370, height),
    (width * 0.5, height),
  )
  p.push((width * 0.5, height))
  p += _spb-cubic(
    (width * 0.5, height),
    (width * 0.77630, height),
    (width, height * 0.84131),
    (width, height * 0.64581),
  )
  p.push((width, height * 0.43449))
  if rtl { p.map(((x, y)) => (width - x, y)) } else { p }
}

#let _spb-cube-icon(size, ink) = {
  let tile-w = size * 0.30
  let tile-h = size * 0.23
  let front = rect(width: tile-w, height: tile-h, radius: 0.04cm, fill: ink)
  let upper-tile = rect(width: tile-w, height: tile-h, radius: 0.04cm,
    fill: ink.transparentize(24%))
  let side = rect(width: tile-w, height: tile-h, radius: 0.04cm,
    fill: ink.lighten(15%))
  box(width: size, height: size, {
    place(top + left, dx: size * 0.34, dy: size * 0.13, upper-tile)
    place(top + left, dx: size * 0.16, dy: size * 0.37, front)
    place(top + left, dx: size * 0.52, dy: size * 0.37, side)
  })
}

/// Draw a single interlocking serpentine-process node with a loop, icon, title, and copy.
/// It adapts one box from the source; the five-node row and full slide are omitted.
#let serpentine-process-box(
  title: [LOREM IPSUM],
  body: [],
  icon: none,
  width: 6.2cm,
  height: auto,
  min-height: 8.8cm,
  direction: auto,
  body-direction: auto,
  colour: rgb("#C83B24"),
  panel-colour: auto,
  title-colour: auto,
  text-colour: auto,
  icon-colour: auto,
  track-colour: auto,
  shadow-colour: auto,
  body-size: 9pt,
  title-size: 15pt,
  body-padding-x: 0.72cm,
  body-start: 5.05cm,
  bottom-padding: 0.90cm,
  shadow-offset: 0.13cm,
  shadow: true,
  body-offset-x: 0pt,
  body-offset-y: 0pt,
  icon-offset-x: 0pt,
  icon-offset-y: 0pt,
  title-offset-x: 0pt,
  title-offset-y: 0pt,
) = context {
  let print-mode = theme-state.get().mode == "print"
  let rtl = if direction == auto { is-rtl() }
    else { direction == "rtl" or direction == std.rtl }
  let body-rtl = if body-direction == auto { rtl }
    else { body-direction == "rtl" or body-direction == std.rtl }
  let body-dir = if body-rtl { std.rtl } else { std.ltr }
  let title-dir = if rtl { std.rtl } else { std.ltr }

  let piece-fill = if print-mode { luma(232) }
    else if panel-colour != auto { panel-colour }
    else { colour }
  let title-ink = if print-mode { luma(24) }
    else if title-colour != auto { title-colour }
    else { white }
  let body-ink = if print-mode { luma(43) }
    else if text-colour != auto { text-colour }
    else { white }
  let icon-ink = if print-mode { luma(55) }
    else if icon-colour != auto { icon-colour }
    else { colour.darken(23%) }
  let path-ink = if print-mode { luma(110) }
    else if track-colour != auto { track-colour }
    else { colour.lighten(27%) }
  let shadow-ink = if shadow-colour != auto { shadow-colour } else { rgb("#364047") }
  let shadow-fill = if print-mode { luma(220) } else { shadow-ink.transparentize(79%) }
  let active-dot = if print-mode { luma(68) } else { colour.darken(9%) }
  let passive-dot = if print-mode { luma(184) } else { colour.lighten(42%) }
  let edge = if print-mode { (paint: luma(130), thickness: 0.8pt) } else { none }

  let body-content = if body-direction == auto {
    {
      set par(leading: 0.46em, spacing: 0.42em, justify: false)
      text(size: body-size, fill: body-ink, body)
    }
  } else {
    {
      set par(leading: 0.46em, spacing: 0.42em, justify: false)
      text(dir: body-dir, size: body-size, fill: body-ink, body)
    }
  }
  let body-width = width - 2 * body-padding-x
  let body-measure = measure(body-content, width: body-width)
  let measured-height = body-start + body-measure.height + bottom-padding
  let final-height = if height == auto { calc.max(min-height, measured-height) }
    else { calc.max(height, measured-height) }

  let points = _spb-piece-points(width, final-height, rtl: rtl)
  let piece = polygon(fill: piece-fill, stroke: edge, ..points)
  let drop = polygon(fill: shadow-fill, stroke: none, ..points)
  let loop-width = width * 0.59
  let loop-height = 1.55cm
  let loop-x = (width - loop-width) / 2
  let loop-y = 0.39cm
  let loop = ellipse(width: loop-width, height: loop-height, fill: none,
    stroke: (paint: path-ink, thickness: if print-mode { 1.2pt } else { 1.6pt }))
  let endpoint-size = 0.16cm
  let loop-mid-y = loop-y + loop-height / 2 - endpoint-size / 2
  let entry-x = if rtl { loop-x + loop-width - endpoint-size } else { loop-x }
  let exit-x = if rtl { loop-x } else { loop-x + loop-width - endpoint-size }
  let entry = ellipse(width: endpoint-size, height: endpoint-size, fill: active-dot)
  let exit = ellipse(width: endpoint-size, height: endpoint-size, fill: passive-dot)

  let disc-size = 1.47cm
  let disc-y = 0.43cm
  let disc-fill = if print-mode { white } else { piece-fill.lighten(65%) }
  let disc-edge = if print-mode { luma(100) } else { piece-fill.lighten(24%) }
  let disc = ellipse(width: disc-size, height: disc-size, fill: disc-fill,
    stroke: (paint: disc-edge, thickness: 0.8pt))
  let icon-content = if icon == none { _spb-cube-icon(disc-size * 0.62, icon-ink) } else { icon }
  let icon-box = box(width: disc-size * 0.76, height: disc-size * 0.76,
    align(center + horizon, icon-content))
  let disc-x = (width - disc-size) / 2
  let icon-x = disc-x + (disc-size - disc-size * 0.76) / 2

  let title-y = 4.05cm
  let title-box = box(width: body-width, height: 0.66cm,
    align(center + horizon,
      text(dir: title-dir, size: title-size, weight: "bold", fill: title-ink, title)))
  let text-x = body-padding-x
  let divider-width = width * 0.53
  let divider-y = 4.89cm
  let divider = rect(width: divider-width, height: 0.025cm,
    fill: if print-mode { luma(120) } else { path-ink })
  let divider-x = (width - divider-width) / 2
  let divider-dot = ellipse(width: 0.12cm, height: 0.12cm,
    fill: if print-mode { luma(75) } else { colour.lighten(40%) })
  let divider-dot-x = (width - 0.12cm) / 2
  let body-box = box(width: body-width,
    height: final-height - body-start - bottom-padding,
    align(center + top, body-content))
  let shadow-x = shadow-offset

  box(width: width + shadow-offset, height: final-height + shadow-offset,
    inset: 0pt, {
      if shadow { place(top + left, dx: shadow-x, dy: shadow-offset, drop) }
      place(top + left, dx: 0pt, dy: 0pt, piece)
      place(top + left, dx: loop-x, dy: loop-y, loop)
      place(top + left, dx: entry-x, dy: loop-mid-y, entry)
      place(top + left, dx: exit-x, dy: loop-mid-y, exit)
      place(top + left, dx: disc-x, dy: disc-y, disc)
      place(top + left, dx: (icon-x) + icon-offset-x, dy: (disc-y + (disc-size - disc-size * 0.76) / 2) + icon-offset-y, icon-box)
      place(top + left, dx: (text-x) + title-offset-x, dy: (title-y) + title-offset-y, title-box)
      place(top + left, dx: divider-x, dy: divider-y, divider)
      place(top + left, dx: divider-dot-x, dy: divider-y - 0.047cm, divider-dot)
      place(top + left, dx: (text-x) + body-offset-x, dy: (body-start) + body-offset-y, body-box)
    })
}
