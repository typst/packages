#import "/src/main.typ": cetz, icons
#set text(font: "FreeSans")

#let icon-set = icons(
  fill: blue,
  fill-inner: white,
  stroke-inner: white,
  stroke: blue.lighten(50%) + 2pt,
  flat: false,
)

#let w = 6
#let h = 6
#let render-all = i => {
  for on-page in i.pairs().chunks(w * h) {
    cetz.canvas(length: 3.5em, {
      cetz.draw.grid(
        (0, 0),
        (w * 2, h * 3 - 1),
        stroke: blue,
        step: 1,
      )
      on-page
        .chunks(w)
        .enumerate()
        .map(((y, c)) => c
          .rev()
          .enumerate()
          .map(((x, (k, v))) => v(
            ((w - x) * 2 - 1, (h - y) * 3 - 2),
            label: box(fill: white)[#k],
          )))
        .flatten()
    })
  }
}

#set page(header: [= 3D])

#render-all(icon-set)

#set page(header: [= Flat])

#render-all(icon-set.pairs().map(((k, v)) => (k, v.with(flat: true))).to-dict())
