
#let heavyrulewidth = 0.08em
#let lightrulewidth = 0.05em
#let cmidrulewidth = 0.03em

#let toprule(stroke: heavyrulewidth) = {
  table.hline(stroke: stroke)
}
#let bottomrule(stroke: heavyrulewidth) = toprule(stroke: stroke)
#let midrule(stroke: lightrulewidth) = {
  table.hline(stroke: stroke)
}

#let cmidrule(y: auto, start: 0, end: none, stroke: cmidrulewidth) = {
  // if end != none and end > 0 {
  //   assert(start >= end, message: "start index should be <= to the end index!")
  // }

  let mystart = 0
  let myend = none
  if start > 0 {
    mystart = start
  }
  if end > 0 {
    myend = end
  }

  table.hline(y: y, stroke: stroke, start: mystart, end: myend)
}