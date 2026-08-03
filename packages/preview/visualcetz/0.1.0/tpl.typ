#import "@preview/cetz:0.5.2"
#import "@preview/cetz-plot:0.1.4": plot, chart, smartart
#import "@preview/cetz-venn:0.2.0"
#import cetz.draw

// ---------- Palette du document ----------
#let acc  = rgb("#1f6feb")
#let acc2 = rgb("#c2410c")
#let bg   = rgb("#f6f8fa")
#let bd   = rgb("#d0d7de")

// ---------- Scope d'évaluation des exemples ----------
#let ex-scope = dictionary(draw) + (
  cetz: cetz,
  canvas: cetz.canvas,
  tree: cetz.tree,
  angle-lib: cetz.angle,
  decorations: cetz.decorations,
  palette: cetz.palette,
  vector: cetz.vector,
  matrix: cetz.matrix,
  util: cetz.util,
  intersection: cetz.intersection,
  // extensions
  plot: plot,
  chart: chart,
  smartart: smartart,
  venn: cetz-venn,
)

// ---------- Rendu d'un exemple : code | résultat ----------
#let ex(src, ratio: 50%, len: 1cm, dbg: false) = {
  let body = (if type(src) == str { src } else { src.text }).trim("\n")
  let pic = eval(
    "canvas(length: " + repr(len) + ", debug: " + repr(dbg) + ", {\n" + body + "\n})",
    mode: "code", scope: ex-scope,
  )
  block(
    breakable: false,
    width: 100%,
    inset: (top: 3pt, bottom: 3pt),
    grid(
      columns: (ratio, 1fr),
      column-gutter: 8pt,
      align: (top + left, horizon + center),
      block(
        width: 100%, fill: bg, radius: 3pt, inset: (x: 5pt, y: 4pt),
        stroke: 0.4pt + bd,
        raw(body, lang: "typc", block: true),
      ),
      block(width: 100%, inset: 2pt, pic),
    ),
  )
}

// Exemple markup complet : les lignes `#import "@preview/..."` sont affichées
// mais retirées avant l'évaluation (eval n'a pas accès au système de fichiers).
#let exr(src, ratio: 50%) = {
  let body = (if type(src) == str { src } else { src.text }).trim("\n")
  let code = body.split("\n").filter(l => not l.starts-with("#import \"@preview")).join("\n")
  block(breakable: false, width: 100%, inset: (top: 3pt, bottom: 3pt),
    grid(columns: (ratio, 1fr), column-gutter: 8pt,
      align: (top + left, horizon + center),
      block(width: 100%, fill: bg, radius: 3pt, inset: (x: 5pt, y: 4pt),
        stroke: 0.4pt + bd, raw(body, lang: "typ", block: true)),
      block(width: 100%, inset: 2pt, eval(code, mode: "markup", scope: ex-scope))))
}

// ---------- Notes / encadrés ----------
#let note(title: "Note", body) = block(
  width: 100%, fill: rgb("#fff8e6"), stroke: (left: 2pt + rgb("#e3b341")),
  inset: (x: 7pt, y: 5pt), radius: 2pt, breakable: false,
  [#text(weight: "bold", size: 8pt)[#title] #h(4pt) #text(size: 8.5pt)[#body]],
)

#let api(sig, ..desc) = block(width: 100%, inset: (y: 2pt))[
  #text(size: 8.5pt)[#raw(sig, lang: "typc")]
  #if desc.pos().len() > 0 [ #linebreak() #text(size: 8pt, fill: rgb("#444"))[#desc.pos().first()] ]
]

// ---------- Réglages document ----------
#let conf(doc) = {
  set page(
    paper: "a4", margin: (x: 1.5cm, y: 1.6cm),
    header: context {
      set text(size: 7.5pt, fill: rgb("#666"))
      grid(columns: (1fr, 1fr), align: (left, right),
        [Visual CeTZ 0.5.2 — guide visuel], [Typst 0.15.1])
      line(length: 100%, stroke: 0.4pt + bd)
    },
    footer: context {
      set text(size: 8pt, fill: rgb("#666"))
      align(center, counter(page).display("1 / 1", both: true))
    },
  )
  set text(font: ("Libertinus Serif", "DejaVu Serif", "New Computer Modern"), size: 9.5pt, lang: "fr")
  show raw: set text(font: ("DejaVu Sans Mono", "Liberation Mono"), size: 7.6pt)
  set par(justify: true, leading: 0.55em)

  set heading(numbering: "1.1")
  show heading.where(level: 1): it => {
    block(width: 100%, above: 18pt, below: 8pt, sticky: true, fill: acc, inset: (x: 8pt, y: 6pt), radius: 3pt,
      text(fill: white, size: 14pt, weight: "bold",
        if it.numbering == none { it.body }
        else [#counter(heading).display() #h(6pt) #it.body]))
    v(2pt)
  }
  show heading.where(level: 2): it => block(above: 12pt, below: 5pt, sticky: true,
    text(fill: acc, size: 11pt, weight: "bold",
      [#counter(heading).display() #h(4pt) #it.body]))
  show heading.where(level: 3): it => block(above: 8pt, below: 3pt, sticky: true,
    text(fill: acc2, size: 9.5pt, weight: "bold", it.body))
  show link: set text(fill: acc)
  doc
}
