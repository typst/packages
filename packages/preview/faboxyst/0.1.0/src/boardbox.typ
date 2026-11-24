// ===========================================================================
//  faboxyst/boardbox.typ — classroom board as a box, after kmbeamer.
//
//    #chalkbox(title: [Lemma])[…]     green slate, eraser + chalks
//    #markerbox(title: [Note])[…]     whiteboard, eraser + markers
// ===========================================================================

#import "fabox.typ": is-rtl

#let bb-colours = (
  kerria:      rgb("#FFA500"),
  brown:       rgb("#763900"),
  goldbrown:   rgb("#C47600"),
  bottlegreen: rgb("#264435"),
  navyblue:    rgb("#1F2F54"),
  satsuma:     rgb("#FA8000"),
  sepia:       rgb("#4A3B2A"),
  deepgreen:   rgb("#005731"),
  snow:        rgb("#F1F1F1"),
  midyellow:   rgb("#FAD43A"),
  water:       rgb("#A9CEEC"),
)

#let _wood-frame(W, H, wood, lit, dim, plate-c, plate, lip) = {
  // outer lit (top + left)
  place(top + left, box(width: W, height: wood, fill: lit))
  place(top + left, box(width: wood, height: H, fill: lit))
  // outer dim, mitred (bottom + right)
  place(top + left, polygon(
    fill: dim,
    (0pt, H), (wood, H - wood), (W, H - wood), (W, H),
  ))
  place(top + left, polygon(
    fill: dim,
    (W, 0pt), (W - wood, wood), (W - wood, H), (W, H),
  ))
  // plate
  let p0 = wood
  let p1w = W - 2 * wood
  let p1h = H - 2 * wood
  place(top + left, dx: p0, dy: p0,
    box(width: p1w, height: plate, fill: plate-c))
  place(top + left, dx: p0, dy: H - wood - plate,
    box(width: p1w, height: plate, fill: plate-c))
  place(top + left, dx: p0, dy: p0,
    box(width: plate, height: p1h, fill: plate-c))
  place(top + left, dx: W - wood - plate, dy: p0,
    box(width: plate, height: p1h, fill: plate-c))
  // inner lip
  let i0 = wood + plate
  let i1w = W - 2 * i0
  let i1h = H - 2 * i0
  place(top + left, dx: i0, dy: i0,
    box(width: i1w, height: lip, fill: dim))
  place(top + left, dx: i0, dy: i0,
    box(width: lip, height: i1h, fill: dim))
  place(top + left, dx: i0, dy: H - i0 - lip,
    box(width: i1w, height: lip, fill: lit))
  place(top + left, dx: W - i0 - lip, dy: i0,
    box(width: lip, height: i1h, fill: lit))
}

#let _eraser(x, y, w, h, rtl) = {
  // navy felt, orange body, sepia handle, five studs
  place(top + left, dx: x, dy: y + h * 0.42,
    box(width: w, height: h * 0.50, fill: bb-colours.navyblue, radius: 0.04cm))
  place(top + left, dx: x - 0.04cm, dy: y + h * 0.12,
    box(width: w + 0.08cm, height: h * 0.38, fill: bb-colours.satsuma, radius: 0.04cm))
  place(top + left, dx: x + w * 0.40, dy: y,
    box(width: w * 0.20, height: h * 0.42, fill: bb-colours.sepia, radius: 0.03cm))
  for k in range(5) {
    let cx = x + w * (0.12 + k * 0.19)
    place(top + left, dx: cx - 0.04cm, dy: y + h * 0.48,
      circle(radius: 0.04cm, fill: bb-colours.deepgreen))
  }
}

#let _chalk(x, y, w, h, col) = {
  place(top + left, dx: x, dy: y,
    box(width: w, height: h * 0.52, fill: col, radius: 0.04cm))
  place(top + left, dx: x, dy: y + h * 0.48,
    box(width: w, height: h * 0.48, fill: luma(145), radius: (bottom: 0.04cm)))
}

#let _marker(x, y, w, h, col) = {
  let cap = w * 0.28
  place(top + left, dx: x, dy: y,
    box(width: cap, height: h, fill: col, radius: (left: 0.05cm, right: 0pt)))
  place(top + left, dx: x + cap * 0.78, dy: y + h * 0.08,
    box(width: w - cap, height: h * 0.84, fill: luma(235),
      radius: (right: 0.04cm), stroke: 0.4pt + col.darken(15%)))
  place(top + left, dx: x + cap * 0.70, dy: y + h * 0.18,
    box(width: 0.07cm, height: h * 0.64, fill: col.darken(10%)))
}

#let boardbox(
  body,
  title: none,
  kind: "chalk",
  colour: auto,
  fill: auto,
  title-colour: auto,
  text-fill: auto,
  grid: true,
  grid-step: 0.32cm,
  tray: true,
  border: 0.16cm,
  inset: 0.32cm,
  width: 100%,
  direction: auto,
) = context {
  let rtl = if direction != auto { direction == std.rtl } else { is-rtl() }
  let body-dir = if rtl { std.rtl } else { ltr }
  let chalk = kind != "marker"
  let slate = if fill != auto { fill }
              else if chalk { bb-colours.bottlegreen } else { rgb("#F4F5F2") }
  let lit = if chalk { bb-colours.kerria } else { rgb("#D8DCE0") }
  let dim = if chalk { bb-colours.brown } else { rgb("#8E979E") }
  let plate = if chalk { bb-colours.goldbrown } else { rgb("#B9C0C6") }
  let ink = if text-fill != auto { text-fill }
            else if chalk { bb-colours.snow } else { rgb("#1A1A1A") }
  let tc = if title-colour != auto { title-colour }
           else if chalk { bb-colours.water } else { rgb("#1776C7") }
  let accent = if colour != auto { colour } else { tc }

  let wood = border
  let plate-w = border * 0.80
  let lip = border * 0.44
  let tray-h = if tray { 0.58cm } else { 0pt }
  let frame = wood + plate-w + lip

  let title-body = if title == none { none } else {
    text(fill: tc, weight: "bold", size: 0.95em, title)
  }
  let tm = if title-body == none { (width: 0pt, height: 0pt) }
           else { measure(title-body) }
  let title-h = if title == none { 0pt } else { tm.height + 0.16cm }

  layout(avail => {
    let W = if type(width) == ratio { avail.width * width } else { width }
    let inner-w = W - 2 * frame - 2 * inset
    let main = block(width: inner-w, {
      set text(dir: body-dir, fill: ink)
      set align(start)
      body
    })
    let mh = measure(main).height
    let slate-h = title-h + mh + 2 * inset + tray-h
    let H = slate-h + 2 * frame

    block(width: W, height: H, {
      set text(dir: ltr)
      _wood-frame(W, H, wood, lit, dim, plate, plate-w, lip)

      let sx = frame
      let sy = frame
      let sw = W - 2 * frame
      let sh = H - 2 * frame
      place(top + left, dx: sx, dy: sy,
        box(width: sw, height: sh, fill: slate))

      if grid {
        let g = if luma(slate).components().first() > 50% {
          slate.darken(5%)
        } else { slate.lighten(7%) }
        let step = grid-step
        let x = step
        while x < sw {
          place(top + left, dx: sx + x, dy: sy,
            line(length: sh, angle: 90deg,
              stroke: (paint: g, thickness: 0.25pt)))
          x = x + step
        }
        let y = step
        while y < sh {
          place(top + left, dx: sx, dy: sy + y,
            line(length: sw, angle: 0deg,
              stroke: (paint: g, thickness: 0.25pt)))
          y = y + step
        }
      }

      if tray {
        let er-w = 1.32cm
        let er-h = 0.50cm
        let stick-w = 1.02cm
        let stick-h = 0.24cm
        let mark-h = 0.28cm
        let gap = 0.10cm
        let base = sy + sh
        let eraser-x = if rtl { sx + 0.10cm } else { sx + sw - 0.10cm - er-w }
        _eraser(eraser-x, base - er-h, er-w, er-h, rtl)
        let cols = if chalk {
          (bb-colours.snow, bb-colours.midyellow, bb-colours.water)
        } else {
          (rgb("#1A1A1A"), rgb("#1565C0"), rgb("#C62828"))
        }
        for (i, col) in cols.enumerate() {
          let sx0 = if rtl {
            eraser-x + er-w + gap + i * (stick-w + gap)
          } else {
            eraser-x - (i + 1) * (stick-w + gap)
          }
          if chalk {
            _chalk(sx0, base - stick-h, stick-w, stick-h, col)
          } else {
            _marker(sx0, base - mark-h, stick-w, mark-h, col)
          }
        }
      }

      if title != none {
        let tx = if rtl { sx + sw - inset - tm.width } else { sx + inset }
        place(top + left, dx: tx, dy: sy + inset * 0.6, {
          set text(dir: body-dir)
          title-body
        })
      }
      let by = sy + inset * 0.6 + title-h
      place(top + left, dx: sx + inset, dy: by, main)
    })
  })
}

#let chalkbox(body, ..a) = boardbox(body, kind: "chalk", ..a)
#let markerbox(body, ..a) = boardbox(body, kind: "marker", ..a)
