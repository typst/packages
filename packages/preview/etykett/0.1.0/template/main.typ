#import "@preview/etykett:0.1.0"

#let data = csv("data.csv").slice(1)

#let name-label((first-name, last-name)) = [
  #set align(center+horizon)
  #set text(14pt)
  Hello, my name is\
  #set text(1.4em)
  *#first-name #last-name*
]

#etykett.labels(
  sheet: etykett.sheet(
    paper: "a4",
    margins: (
      top: 14mm,
      bottom: 15mm,
      x: 6mm,
    ),
    gutters: (x: 2.5mm),
    rows: 9,
    columns: 3,
  ),
  // upside-down: true,
  // sublabels: (
  //   rows: 1,
  //   columns: 5,
  // ),
  debug: true,

  ..etykett.skip(3),
  ..data.map(name-label),
)
