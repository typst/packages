#let default-formatter = body => {
  rect(stroke: .5pt, body)
}

#let inline-answers = (formatter: default-formatter, doc) => {
  state("___inline-answers___", none).update(x => formatter)
  doc
}
