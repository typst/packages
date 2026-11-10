#import "theme.typ": *

// Gestion du logo et de la couverture
#let logo-ece(width: 5.5cm) = image("../assets/images/logo-ece.svg", width: width)

#let _render-logo(logo, width: 5.5cm) = {
  if logo == none {
    none
  } else if type(logo) == content {
    logo
  } else if logo == auto {
    image("../assets/images/logo-ece.svg", width: width)
  } else if type(logo) == str {
    image(logo, width: width)
  } else {
    logo
  }
}

#let _render-cover(cover) = {
  if cover == none {
    none
  } else if type(cover) == content {
    cover
  } else if cover == auto {
    image("../assets/images/elec.png", width: 100%)
  } else if type(cover) == str {
    image(cover, width: 100%)
  } else {
    cover
  }
}

// Éléments de rédaction (questions de TP, notes, alertes)
#let question(label, body) = [
  #v(0.6em, weak: true)
  #text(fill: ece, weight: "bold")[#label.] #body
  #v(0.4em, weak: true)
]

#let t(num, body) = question("T" + str(num), body)
#let e(num, body) = question("E" + str(num), body)

#let nb(body, prefix: "NB :") = [
  #text(weight: "bold")[#prefix] #body
]

#let note(body, prefix: "Note:") = [
  #text(weight: "bold")[#prefix] #body
]

#let attention(body) = [
  #text(fill: warning-red, weight: "bold")[#body]
]

#let todo(body) = [
  #highlight(fill: rgb("#FFF59D"))[#text(weight: "bold")[#body]]
]

#let callout(
  body,
  title: none,
  type: "info",
  fill: auto,
  stroke: auto,
) = {
  let (default_fill, default_stroke) = if type in ("warning", "avertissement", "warn") {
    (rgb("#FEF8E7"), gamboge)
  } else if type in ("danger", "erreur", "error") {
    (rgb("#FDF0F0"), warning-red)
  } else if type in ("tip", "astuce") {
    (rgb("#EBF0F8"), darkpowderblue)
  } else {
    (rgb("#EBF5F5"), ece)
  }
  let actual_fill = if fill != auto { fill } else { default_fill }
  let actual_stroke = if stroke != auto { stroke } else { default_stroke }
  let title_color = if stroke != auto { stroke } else { default_stroke }

  rect(
    width: 100%,
    fill: actual_fill,
    stroke: 1pt + actual_stroke,
    radius: 4pt,
    inset: 12pt,
  )[
    #if title != none [
      #text(fill: title_color, weight: "bold", size: 1.05em)[#title]
      #v(0.3em)
    ]
    #body
  ]
}

#let note-cadre = callout

// Tableaux d'ingénierie
#let table-ece(headers: (), ..args) = {
  let header-row = if headers != () {
    (table.header(..headers.map(h => if type(h) == str { text(weight: "bold")[#h] } else { h })),)
  } else {
    ()
  }
  table(..header-row, ..args)
}
#let ece-table = table-ece
#let tableau-ece = table-ece

#let table-double-entree(
  columns: auto,
  headers: (),
  align: auto,
  inset: 7pt,
  ..cells
) = {
  let cols = if type(columns) == int {
    (1fr,) * columns
  } else if columns == auto {
    if headers != () and type(headers) == array {
      (1.4fr,) + (1fr,) * (headers.len() - 1)
    } else {
      auto
    }
  } else if type(columns) == array {
    columns.map(c => if type(c) in (int, float) { c * 1fr } else { c })
  } else {
    columns
  }

  let header-row = if headers != () {
    (table.header(..headers.map(h => if type(h) == str { text(weight: "bold")[#h] } else { h })),)
  } else {
    ()
  }

  let default-align = (col, row) => if col == 0 { left + horizon } else { center + horizon }

  let stroke-fn = (x, y) => {
    let base = 0.5pt + rgb("#DDDDDD")
    let b = if y == 0 { 1.5pt + ece } else { base }
    let r = if x == 0 { 1.5pt + ece } else { base }
    (top: base, left: base, bottom: b, right: r)
  }

  let fill-fn = (col, row) => {
    if row == 0 or col == 0 {
      rgb("#EBF5F5")
    } else if calc.even(row) {
      rgb("#FAFAFA")
    } else {
      none
    }
  }

  show table.cell.where(x: 0): set text(weight: "bold")

  table(
    columns: cols,
    stroke: stroke-fn,
    fill: fill-fn,
    inset: inset,
    align: if align != auto { align } else { default-align },
    ..header-row,
    ..cells
  )
}
#let tableau-double-entree = table-double-entree
#let table-2entrees = table-double-entree
#let tableau-2entrees = table-double-entree
#let table-matrice = table-double-entree
#let tableau-matrice = table-double-entree

#let table-2col(
  headers: (),
  ratio: (1fr, 2fr),
  align: auto,
  inset: 7pt,
  columns: auto,
  ..cells
) = {
  let cols = if columns != auto {
    columns
  } else if type(ratio) == array {
    ratio.map(r => if type(r) in (int, float) { r * 1fr } else { r })
  } else if ratio == "equal" or ratio == "50/50" {
    (1fr, 1fr)
  } else {
    (1fr, 2fr)
  }
  let header-row = if headers != () {
    (table.header(..headers.map(h => if type(h) == str { text(weight: "bold")[#h] } else { h })),)
  } else {
    ()
  }
  let args = (:)
  if align != auto { args.insert("align", align) }
  table(
    columns: cols,
    inset: inset,
    ..args,
    ..header-row,
    ..cells
  )
}
#let tableau-2col = table-2col
#let table-double-colonne = table-2col
#let tableau-double-colonne = table-2col

// Annexes
#let annexes(body, lang: "fr", title-prefix: auto) = {
  pagebreak()
  counter(heading).update(0)
  counter(math.equation).update(0)
  counter(figure.where(kind: image)).update(0)
  counter(figure.where(kind: table)).update(0)
  counter(figure.where(kind: raw)).update(0)
  let prefix = if title-prefix != auto {
    title-prefix
  } else if lang == "en" {
    "Appendix "
  } else {
    "Annexe "
  }
  set heading(numbering: (..nums) => {
    let pos = nums.pos()
    if pos.len() == 1 {
      prefix + numbering("A", pos.first()) + " :"
    } else {
      numbering("A.1", ..pos)
    }
  })
  set math.equation(numbering: (..nums) => context {
    let h_count = counter(heading).get().first()
    let letter = numbering("A", calc.max(1, h_count))
    "(" + letter + "." + str(nums.pos().first()) + ")"
  })
  set figure(numbering: (..nums) => context {
    let h_count = counter(heading).get().first()
    let letter = numbering("A", calc.max(1, h_count))
    letter + "." + str(nums.pos().first())
  })
  show heading.where(level: 1): it => {
    it
    counter(figure.where(kind: image)).update(0)
    counter(figure.where(kind: table)).update(0)
    counter(figure.where(kind: raw)).update(0)
    counter(math.equation).update(0)
  }
  body
}
#let appendix = annexes
