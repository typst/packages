// tpl.typ — mise en page du guide « Visual CeTZ ».
//
// LES FONCTIONS D'EXEMPLE VIENNENT DU PAQUET, plus de ce fichier.
// `ex()`, `exr()`, `note()` et `api()` sont désormais exposées par
// `visual-cetz` : le guide s'en sert comme n'importe quel lecteur, ce qui
// est la meilleure preuve qu'elles marchent. Ne restent ici que la mise en
// page (`conf`) et le contexte d'évaluation élargi aux extensions.
#import "@preview/visual-cetz:0.1.0": ex as _ex, exr as _exr, note, api
#import "@preview/visual-cetz:0.1.0": with-scope, cetz-scope
#import "@preview/cetz:0.5.2"
#import "@preview/cetz-plot:0.1.4": plot, chart, smartart
#import "@preview/cetz-venn:0.2.0"

// ---------- Palette du document ----------
#let acc  = rgb("#1f6feb")
#let acc2 = rgb("#c2410c")
#let bg   = rgb("#f6f8fa")
#let bd   = rgb("#d0d7de")

// ---------- Scope d'évaluation des exemples ----------
//
// Le paquet ne connaît que CeTZ : il n'a pas à imposer le téléchargement de
// `cetz-plot` et `cetz-venn` à qui n'en veut pas, ni à figer leurs versions.
// Le guide, lui, les documente — il les ajoute donc au contexte.
#let ex-scope = with-scope((
  plot: plot,
  chart: chart,
  smartart: smartart,
  venn: cetz-venn,
))

// Les chapitres appellent `ex(...)` sans passer le scope à chaque fois.
#let ex(src, ..args) = _ex(src, scope: ex-scope, ..args)
#let exr(src, ..args) = _exr(src, scope: ex-scope, ..args)

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
