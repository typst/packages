#let footcite(source) = [
  #footnote()[#cite(source, form: "prose")]
]

#let footcitesuf(source, suffix) = [
  #footnote()[#cite(source, form: "prose"), #suffix]
]
