// Reusable process / cycle diagram (replica of the methodology.png style).
// Import with:  #import "process.typ": process
//
// Requires the "Font Awesome 7 Free" font installed for the icons.
//
//   #process(
//     (
//       ("\u{f02d}", "1. Review and selection of existing methods."),  // book
//       ("\u{f51e}", "2. Data collection."),                          // coins
//       ("\u{f83e}", "3. Analysis of signal patterns."),              // wave-square
//       ("\u{f023}", "4. Development of the authentication model."),   // lock
//       ("\u{f46c}", "5. Evaluation and validation of the system."),   // clipboard-check
//       ("\u{f080}", "6. Documentation and dissemination of results."),// chart-bar
//     ),
//   )
//
// Items: 6 tuples (icon-glyph, label). First three render on the left, last
// three on the right (mirrored). Any Font Awesome codepoint works as the glyph.
#import "common.typ": _dot, _put, _tallest, _u

#let fa = "Font Awesome 7 Free"

#let process(
  items,
  core: text(font: "Font Awesome 7 Free", size: 64pt, fill: rgb("#e64553"))[\u{f21e}], // heartbeat
  accent: rgb("#73c25a"),     // tab + connector + ring-dot color (medium green)
  badge-color: rgb("#a7dd9b"), // icon badge (light green)
  icon-color: white,          // icon glyph color inside the badge
  ring: rgb("#e64553"),       // central ring color
  box-fill: rgb("#ebedf5"),   // pale lavender-grey, like the original
  box-radius: 0pt,            // square corners, like the original
  box-h: 3cm,               // badge diameter and minimum card height
  ring-radius: 3,
) = context {
  // every card takes the tallest label's height (box-h is the minimum); badges keep box-h
  let card-h = calc.max(box-h, 28pt + _tallest(items.map(it => {
    set par(justify: false, leading: 0.5em)
    text(size: 16pt, it.at(1))
  }), 8cm - box-h / 2 - 0.9cm))
  let lefts = items.slice(0, calc.min(3, items.len()))
  let rights = if items.len() > 3 { items.slice(3) } else { () }
  let pitch = calc.max(4.3cm, card-h + 1.3cm)
  let yrows = (pitch, 0cm, -pitch)
  let bx = 9cm                      // box center x
  let inner = 5cm                   // box inner edge (where the green tab + line start) = bx - box-w/2
  let box-w = 8cm
  let line-thickness = 4pt        // connector line thickness
  let ring-thickness = 8pt          // central ring thickness

  // ---- per-item colour: a tuple may carry an optional 3rd element = its colour.
  //      none -> fall back to the global green. tab/line/dot use it; badge a lighter tint.
  let item-color(it) = it.at(2, default: none)
  let tab-color(col) = if col == none { accent } else { col }
  let badge-fill(col) = if col == none { badge-color } else { col.lighten(45%) }

  // ---- one item box: label card + overlapping icon badge + inner tab ----
  // badge diameter == box height
  let badge(icon, col) = circle(radius: box-h / 2, fill: col, stroke: none,
    align(center + horizon, text(font: fa, fill: icon-color, size: box-h * 0.42)[#icon]))
  let node(icon, label, mirror, col) = {
    let pad-icon = box-h / 2 + 0.3cm   // clear the half of the badge that sits inside
    let body = box(fill: box-fill, radius: box-radius, width: box-w, height: card-h,
      inset: (y: 14pt,
        left: if mirror { 0.6cm } else { pad-icon },
        right: if mirror { pad-icon } else { 0.6cm }))[
      #set text(size: 16pt)
      #set par(justify: false, leading: 0.5em)
      #align(horizon)[#label]   // vertical-centre the text in the fixed-height card
    ]
    box(width: box-w, height: card-h)[
      #body
      // tab on the inner edge (toward the centre)
      #place((if mirror { left } else { right }) + horizon,
        box(width: 0.3cm, height: 100%, fill: tab-color(col)))
      // icon badge: diameter == box height, centre aligned to the box outer edge
      #place((if mirror { right } else { left }) + horizon,
        dx: if mirror { box-h / 2 } else { -box-h / 2 }, badge(icon, badge-fill(col)))
    ]
  }

  let r = _u(ring-radius)
  let elbow-x = 4.2cm
  let rows = calc.max(lefts.len(), rights.len())
  let half-w = bx + box-w / 2 + box-h / 2
  let x0 = half-w
  let y0 = calc.max(yrows.at(0) + card-h / 2, r + ring-thickness / 2)
  let width = x0 + if rights.len() > 0 { half-w } else { r + ring-thickness / 2 }
  let height = y0 + calc.max(-yrows.at(rows - 1) + card-h / 2, r + ring-thickness / 2)
  box(width: width, height: height, {
    // connectors first (behind ring + boxes): short horizontal stub off the box,
    // then a diagonal to the ring — the dog-leg shape of the original.
    let ring-dots = ()
    for (side, group) in ((-1, lefts), (1, rights)) {
      for (i, it) in group.enumerate() {
        let by = yrows.at(i)
        let col = tab-color(item-color(it))
        let d = calc.norm(elbow-x / 1cm, by / 1cm) * 1cm
        let rp = (x0 + side * elbow-x / d * r, y0 - by / d * r)   // point on the ring
        // single polyline so the elbow has a clean rounded join (no notch)
        place(top + left, curve(stroke: (paint: col, thickness: line-thickness, join: "round", cap: "round"),
          curve.move((x0 + side * inner, y0 - by)), curve.line((x0 + side * elbow-x, y0 - by)), curve.line(rp)))
        ring-dots.push((rp, col))
      }
    }
    _dot(x0, y0, r, fill: white, stroke: ring-thickness + ring)
    _put(x0, y0, core)
    // hollow ring-edge dots on top of the ring
    for ((x, y), col) in ring-dots { _dot(x, y, 0.17cm, fill: white, stroke: 2.6pt + col) }
    for (side, group) in ((-1, lefts), (1, rights)) {
      for (i, it) in group.enumerate() {
        place(top + left, dx: x0 + side * bx - box-w / 2, dy: y0 - yrows.at(i) - card-h / 2,
          node(it.at(0), it.at(1), side > 0, item-color(it)))
      }
    }
  })
}
