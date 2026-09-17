// Reusable process / cycle diagram (replica of the methodology.png style).
// Import with:  #import "process.typ": process
//
// Requires the "Font Awesome 7 Free" font installed for the icons, and the
// cetz package (auto-downloaded by Typst on first compile).
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
#import "@preview/cetz:0.5.2": canvas, draw

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
  box-h: 3cm,               // fixed height so every card is the same size
  ring-radius: 3,
) = {
  let lefts = items.slice(0, calc.min(3, items.len()))
  let rights = if items.len() > 3 { items.slice(3) } else { () }
  let yrows = (4.3, 0, -4.3)
  let bx = 9                        // box center x
  let inner = 5                     // box inner edge (where the green tab + line start) = bx - box-w/2
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
    let body = box(fill: box-fill, radius: box-radius, width: box-w, height: box-h,
      inset: (y: 14pt,
        left: if mirror { 0.6cm } else { pad-icon },
        right: if mirror { pad-icon } else { 0.6cm }))[
      #set text(size: 16pt)
      #set par(justify: false, leading: 0.5em)
      #align(horizon)[#label]   // vertical-centre the text in the fixed-height card
    ]
    box(width: box-w)[
      #body
      // tab on the inner edge (toward the centre)
      #place((if mirror { left } else { right }) + horizon,
        box(width: 0.3cm, height: 100%, fill: tab-color(col)))
      // icon badge: diameter == box height, centre aligned to the box outer edge
      #place((if mirror { right } else { left }) + horizon,
        dx: if mirror { box-h / 2 } else { -box-h / 2 }, badge(icon, badge-fill(col)))
    ]
  }

  canvas({
    import draw: *
    let r = ring-radius
    // hollow ring-dot, coloured per item
    let hdot(p, col) = circle(p, radius: 0.17, fill: white, stroke: 2.6pt + col)

    // connectors first (behind ring + boxes): short horizontal stub off the box,
    // then a diagonal to the ring — the dog-leg shape of the original.
    let elbow-x = 4.2
    let ring-dots = ()
    for (side, group) in ((-1, lefts), (1, rights)) {
      for (i, it) in group.enumerate() {
        let by = yrows.at(i)
        let col = tab-color(item-color(it))
        let tp = (side * inner, by)         // inner edge / tab
        let el = (side * elbow-x, by)       // bend where the stub meets the diagonal
        let dx = side * elbow-x
        let d = calc.sqrt(dx * dx + by * by)
        let rp = (dx / d * r, by / d * r)   // point on the ring
        // single polyline so the elbow has a clean rounded join (no notch)
        line(tp, el, rp, stroke: (paint: col, thickness: line-thickness, join: "round", cap: "round"))
        ring-dots.push((rp, col))
      }
    }

    // central ring
    circle((0, 0), radius: r, stroke: ring-thickness + ring, fill: white)
    content((0, 0), core)

    // hollow ring-edge dots drawn last, so they sit on top of the ring
    for (rp, col) in ring-dots { hdot(rp, col) }

    // boxes on top of the connector ends
    for (i, it) in lefts.enumerate() {
      content((-bx, yrows.at(i)), node(it.at(0), it.at(1), false, item-color(it)))
    }
    for (i, it) in rights.enumerate() {
      content((bx, yrows.at(i)), node(it.at(0), it.at(1), true, item-color(it)))
    }
  })
}
