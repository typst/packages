// Waffle: a grid of squares showing shares of a whole, with a legend.
// Import with:  #import "waffle.typ": waffle
//
//   #waffle((([Responders], 62), ([Partial], 23), ([No change], 15)))
#import "common.typ": _canvas, _items, _lens, _theme, _txt

#let waffle(
  items,
  total: 100,
  columns: 10,
  cell: 0.9em,
  gap: 0.2em,
  text-size: 1em,
  width: auto,
  theme: (:),
  ..style,
) = layout(area => {
  let t = _theme("waffle", theme, style)
  let items = _items("waffle", items, t.palette, fields: ("label", "count"), numbers: ("count",))
  for (i, it) in items.enumerate() {
    if not (type(it.count) == int) { assert(false, message: "waffle: the count of item " + str(i + 1) + " must be an integer, got "
      + repr(it.count)) }
  }
  let (cell, gap, size, em) = _lens("waffle", cell: cell, gap: gap, text-size: text-size, em: 1em).values()
  // cell i takes the colour of the part whose running total first exceeds i
  let ends = items.map(it => it.count)
  let cum = range(ends.len()).map(k => ends.slice(0, k + 1).sum())
  let colour(i) = {
    let k = cum.position(c => i < c)
    if k == none { t.panel } else { items.at(k).fill }
  }
  let swatch = size * t.small
  let captions = items.map(it => _txt([#it.label · #it.count], t.ink, size * t.small, weight: auto))
  let legend = grid(columns: 2, column-gutter: 0.35 * em, row-gutter: 0.35 * em, align: horizon,
    ..items.zip(captions).map(((it, caption)) => (
      box(width: swatch, height: swatch, radius: swatch / 5, fill: it.fill), caption)).flatten())
  let (lattice-w, lattice-h) = (columns * (cell + gap) - gap, calc.ceil(total / columns) * (cell + gap) - gap)
  // measuring a grid that is also laid out costs a second layout iteration, so the
  // legend's size is added up from its captions
  let sizes = captions.map(caption => measure(caption))
  let legend-w = swatch + 0.35 * em + calc.max(..sizes.map(m => m.width))
  let legend-h = sizes.map(m => calc.max(swatch, m.height)).sum() + (items.len() - 1) * 0.35 * em
  let spacing = 0.7 * em
  _canvas("waffle", t, width, area, calc.max(lattice-w, legend-w), lattice-h + spacing + legend-h,
    stack(dir: ttb, spacing: spacing,
      // cells are placed directly: no grid track sizing for a fixed lattice
      box(width: lattice-w, height: lattice-h,
        for i in range(total) {
          place(top + left, dx: calc.rem(i, columns) * (cell + gap), dy: calc.quo(i, columns) * (cell + gap),
            box(width: cell, height: cell, radius: cell / 5, fill: colour(i)))
        }),
      legend))
})
