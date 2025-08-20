#import "../main.typ": *

#let nice-border(S, T, p) = place(top+left, polygon(
  (S, S), (100% - S, S), (100% - S, 100% - S), (S, 100% - S),
  (S, S), (T, T), ((T, 100% - T)), (100% - T, 100% - T), (100% - T, T), 
  (T, T), fill: p
))

#let lred = red.lighten(50%)
#let patsize = (16pt, 8pt)

#set page(
  background: {
    nice-border(10mm, 20mm, modpattern(
      patsize,
      {
        place(line(start: (0%,0%), end: (100%, 100%), stroke: 2pt))
        place(line(start: (100%,0%), end: (0%, 100%), stroke: 2pt))
      },
      background: lred,
    ))
    nice-border(8mm, 11.2mm, modpattern(
      patsize,
      line(start: (0%,0%), end: (100%, 100%), stroke: 2pt),
      background: lred
    ))
    nice-border(19.8mm, 22mm, modpattern(
      patsize,
      line(start: (100%,0%), end: (0%, 100%), stroke: 2pt),
      background: lred
    ))
  },
  margin: 3cm
)
#set par(justify: true)
#show heading: it => {
  set text(30pt, fill: modpattern(
      (10pt, 5pt),
      {
        place(line(start: (0%,0%), end: (100%, 100%)))
        place(line(start: (100%,0%), end: (0%, 100%)))
      },
      background: red.lighten(50%)
    ))
  it
}

= Hello Dear People
#lorem(500)