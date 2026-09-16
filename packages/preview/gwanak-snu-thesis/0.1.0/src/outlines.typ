#let _outline-title(title) = {
  align(center)[#text(size: 16pt, weight: "bold")[#title]]
  v(8mm)
}

#let contents-outline(label-set, language, fonts) = {
  set text(font: fonts, lang: language, script: auto, top-edge: 0.8em, bottom-edge: -0.2em)
  _outline-title(label-set.contents)
  set outline.entry(fill: repeat[.])
  outline(title: none)
}

#let table-outline(label-set, language, fonts) = {
  set text(font: fonts, lang: language, script: auto, top-edge: 0.8em, bottom-edge: -0.2em)
  _outline-title(label-set.tables)
  set outline.entry(fill: repeat[.])
  outline(title: none, target: figure.where(kind: table))
}

#let figure-outline(label-set, language, fonts) = {
  set text(font: fonts, lang: language, script: auto, top-edge: 0.8em, bottom-edge: -0.2em)
  _outline-title(label-set.figures)
  set outline.entry(fill: repeat[.])
  outline(title: none, target: figure.where(kind: image))
}
