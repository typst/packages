// nibframe — gallery, part 4: certificates and security-print models.
//   typst compile --root . examples/gallery4.typ                  (français)
//   typst compile --root . --input lang=en examples/gallery4.typ  (English)
#import "../lib.typ": *

#let lang = sys.inputs.at("lang", default: "fr")
#let T(fr, en) = if lang == "en" { en } else { fr }
#set text(font: "Libertinus Serif", size: 11pt, fill: rgb("#2b2622"), lang: lang)
#set page(paper: "a4", fill: rgb("#fbf7ee"))

#let card(s, ..o) = align(center, stack(dir: ttb, spacing: 3pt,
  frame-graphic(112pt, 140pt, style: s, band: 6mm, inset: 2.5mm, paper: rgb("#fbf7ee"), ..o),
  text(size: 9pt, raw(s))))
#{
  set page(margin: 14mm)
  align(center, text(size: 24pt, weight: "bold")[nibframe])
  v(-2pt)
  align(center, text(size: 10pt, style: "italic")[#T("diplômes et guilloché de sécurité", "certificates and security-print models")])
  v(8pt)
  let blue = rgb("#2c4a9a")
  let lblue = rgb("#7d8fd0")
  let plum = rgb("#6a3a8a")
  grid(columns: (1fr,) * 4, row-gutter: 12pt,
    card("certificate", color: blue, accent: lblue, texture: "rosettes"),
    card("certificate-ribbon", color: blue, accent: lblue, texture: "rosettes"),
    card("medallion", color: plum, accent: lblue, texture: "rosettes"),
    card("rosette-ribbon", color: rgb("#4d4d5a"), accent: rgb("#8a8a9a"), texture: "rosettes"),
    card("fleur-edge", color: plum, accent: lblue, texture: "rosettes"),
    card("diamond-chain", color: rgb("#3a6a8a"), accent: rgb("#7a9a9a"), texture: "rosettes"),
    card("diploma-shell", color: rgb("#3a6a8a"), accent: rgb("#7a9a9a"), texture: "waves"),
    card("lace-grid", color: rgb("#2c4a9a"), accent: rgb("#7d8fd0"), texture: "rosettes"),
    card("stepped", color: rgb("#7a2a3a"), accent: rgb("#c9962c")),
    card("deckle", color: rgb("#7a2a3a"), accent: rgb("#c9962c"), texture: "waves"),
    card("label", color: rgb("#7a2a3a"), accent: rgb("#c9962c")),
    card("filigree", color: rgb("#2c3a5a"), accent: rgb("#9aa6c8"), texture: "waves"),
    card("dedication", color: rgb("#2c3a5a"), accent: rgb("#b07a1c")),
    card("plank", color: rgb("#7a2a3a"), accent: rgb("#b07a1c")),
    card("torn", color: rgb("#7a2a3a"), accent: rgb("#c9962c")),
    card("coil", color: rgb("#d6538f"), accent: rgb("#8a5aa8")),
  )
}
