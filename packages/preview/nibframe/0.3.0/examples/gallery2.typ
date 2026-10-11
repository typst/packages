// nibframe — gallery, part 2: the ten latest styles.
//   typst compile --root . examples/gallery2.typ                  (français)
//   typst compile --root . --input lang=en examples/gallery2.typ  (English)
#import "../lib.typ": *

#let lang = sys.inputs.at("lang", default: "fr")
#let T(fr, en) = if lang == "en" { en } else { fr }
#set text(font: "Libertinus Serif", size: 11pt, fill: rgb("#2b2622"), lang: lang)
#set page(paper: "a4", fill: rgb("#fbf7ee"))

#let ink = rgb("#2b2622")

#let card(s, ..o) = align(center, stack(dir: ttb, spacing: 3pt,
  frame-graphic(112pt, 138pt, style: s, band: 6mm, inset: 2.5mm, paper: rgb("#fbf7ee"), ..o),
  text(size: 9pt, raw(s))))
#{
  set page(margin: 12mm)
  align(center, text(size: 24pt, weight: "bold")[nibframe])
  v(-2pt)
  align(center, text(size: 10pt, style: "italic")[#T("dix styles de plus", "ten more styles")])
  v(6pt)
  let red = rgb("#9a3324")
  let blue = rgb("#1d2a44")
  grid(columns: (1fr,) * 4, row-gutter: 10pt,
    card("airmail", color: rgb("#1d3f8c"), accent: red),
    card("checker", color: blue, accent: rgb("#c9962c")),
    card("stars", color: blue, accent: rgb("#c9962c")),
    card("hearts", color: red, accent: rgb("#c9962c")),
    card("eggdart", color: rgb("#4d6b47"), accent: rgb("#c9962c")),
    card("vitruvian", color: blue, accent: red),
    card("arches", color: rgb("#1c7a78"), accent: rgb("#b07a1c")),
    card("tapa", color: rgb("#6b3a1c"), accent: red),
    card("stripes", color: blue, accent: red),
    card("herringbone", color: rgb("#2f628c"), accent: rgb("#b07a1c")),
  )
}
