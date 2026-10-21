// Opposing: two block arrows facing each other.  Import with:  #import "opposing.typ": opposing
//
//   #opposing(([Pros], [Cons]))
//   #opposing(([Pros], ([Cons], rgb("#e64553"))))
#import "@preview/cetz:0.5.2": canvas, draw
#import "common.typ": palette, _lab, _col

#let opposing(
  items,
  w: 6.5, h: 2.6, notch: 1.3, gap: 0.5,
  text-fill: white, size: 18pt,
) = canvas({
  import draw: *
  let la = items.at(0)
  let ra = items.at(1)
  let rx = -gap / 2
  line((rx - w, -h / 2), (rx - notch, -h / 2), (rx, 0), (rx - notch, h / 2), (rx - w, h / 2),
    close: true, fill: _col(la, 0), stroke: none)
  content((rx - w / 2 - notch / 2, 0), box(width: (w - notch) * 1cm,
    align(center, text(fill: text-fill, weight: "bold", size: size)[#_lab(la)])))
  let lx = gap / 2
  line((lx + w, -h / 2), (lx + notch, -h / 2), (lx, 0), (lx + notch, h / 2), (lx + w, h / 2),
    close: true, fill: _col(ra, 1), stroke: none)
  content((lx + w / 2 + notch / 2, 0), box(width: (w - notch) * 1cm,
    align(center, text(fill: text-fill, weight: "bold", size: size)[#_lab(ra)])))
})
