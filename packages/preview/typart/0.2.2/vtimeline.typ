// Vertical timeline: cards alternating left and right of a central line.
// Import with:  #import "vtimeline.typ": vtimeline
//
//   #vtimeline((("2023", [Pilot study]), ("2024", [Data collection], rgb("#e64553")), ("2025", [Paper])))
#import "common.typ": _col, _txt

#let vtimeline(
  items,
  accent: luma(200),
  text-fill: rgb("#1f1f3a"),
  size: 14pt, date-size: 16pt,
  gap: 10pt,
  radius: 6pt,
) = {
  let card(it, col, side) = box(width: 100%, inset: 10pt, radius: radius, fill: col.lighten(80%),
    stroke: (rest: none, ..((side): 4pt + col)),
    align(left, _txt(it.at(1), text-fill, size, weight: auto)))
  let date(it, col, al) = align(al, _txt(it.at(0), col.darken(15%), date-size))
  // the spine is one grid line, so it never breaks between rows
  grid(columns: (1fr, 0.7cm, 0.7cm, 1fr), inset: (x: 0pt, y: gap / 2), align: horizon,
    grid.vline(x: 2, stroke: accent + 3pt),
    ..items.enumerate().map(((i, it)) => {
      let col = _col(it, i, at: 2)
      let dot = place(right + horizon, dx: 8pt, circle(radius: 8pt, fill: col, stroke: white + 2pt))
      if calc.even(i) {
        (pad(right: 4pt, card(it, col, "right")), dot, [], pad(left: 4pt, date(it, col, left)))
      } else {
        (pad(right: 4pt, date(it, col, right)), dot, [], pad(left: 4pt, card(it, col, "left")))
      }
    }).flatten())
}
