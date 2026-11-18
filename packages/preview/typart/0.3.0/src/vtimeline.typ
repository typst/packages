// Vertical timeline: cards alternating left and right of a central line.
// Import with:  #import "vtimeline.typ": vtimeline
//
//   #vtimeline((("2023", [Pilot study]), ("2024", [Data collection], red), ("2025", [Paper])))
#import "common.typ": _card, _fluid, _items, _lens, _on, _theme, _txt

#let vtimeline(
  items,
  gap: 0.6em,
  text-size: 1em,
  width: auto,
  theme: (:),
  ..style,
) = layout(area => {
  let t = _theme("vtimeline", theme, style)
  let items = _items("vtimeline", items, t.palette, fields: ("date", "label"))
  let (gap, size, em) = _lens("vtimeline", gap: gap, text-size: text-size, em: 1em).values()
  let card(it, side) = {
    let tint = color.mix((it.fill, 20%), (t.surface, 80%))
    _card(t, width: 100%, inset: 0.6 * em, radius: t.corner-radius, fill: tint,
      stroke: (rest: none, ..((side): 0.25 * em + it.fill)),
      align(left, _txt(it.label, _on(t, tint), size, weight: auto)))
  }
  let date(it, al) = align(al, _txt(it.date, t.ink, size))
  let dot-r = 0.5 * em
  // the spine is one grid line, so it never breaks between rows
  block(width: _fluid("vtimeline", width, area), grid(columns: (1fr, 1.2 * em, 1.2 * em, 1fr),
    inset: (x: 0pt, y: gap / 2), align: horizon,
    grid.vline(x: 2, stroke: t.muted + t.thick),
    ..items.enumerate().map(((i, it)) => {
      let dot = place(right + horizon, dx: dot-r, circle(radius: dot-r, fill: it.fill,
        stroke: t.surface + 0.12 * em))
      if calc.even(i) {
        (pad(right: 0.25 * em, card(it, "right")), dot, [], pad(left: 0.25 * em, date(it, left)))
      } else {
        (pad(right: 0.25 * em, date(it, right)), dot, [], pad(left: 0.25 * em, card(it, "left")))
      }
    }).flatten()))
})
