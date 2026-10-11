// nibframe — gallery, part 3: celtic knotwork, floral, arabesque and Islamic styles.
//   typst compile --root . examples/gallery3.typ                  (français)
//   typst compile --root . --input lang=en examples/gallery3.typ  (English)
#import "../lib.typ": *

#let lang = sys.inputs.at("lang", default: "fr")
#let T(fr, en) = if lang == "en" { en } else { fr }
#set text(font: "Libertinus Serif", size: 11pt, fill: rgb("#2b2622"), lang: lang)
#set page(paper: "a4", fill: rgb("#fbf7ee"))

#let card(s, ..o) = align(center, stack(dir: ttb, spacing: 3pt,
  frame-graphic(96pt, 118pt, style: s, band: 5mm, inset: 2mm, paper: rgb("#fbf7ee"), ..o),
  text(size: 9pt, raw(s))))
#{
  set page(margin: 12mm)
  align(center, text(size: 24pt, weight: "bold")[nibframe])
  v(-2pt)
  align(center, text(size: 10pt, style: "italic")[#T("celtique, floral, arabesque, islamique", "Celtic, floral, arabesque, Islamic")])
  v(6pt)
  let red = rgb("#9a3324")
  let blue = rgb("#1d2a44")
  let gold = rgb("#b07a1c")
  grid(columns: (1fr,) * 5, row-gutter: 10pt,
    card("knot-cartouche", color: rgb("#2f628c"), accent: gold),
    card("knot-eights", color: rgb("#4d7b47"), accent: gold),
    card("knot-lozenge", color: red, accent: gold),
    card("knot-ring", color: rgb("#2f628c"), accent: red),
    card("knot-rope", color: rgb("#2f628c"), accent: gold),
    card("knot-triple", color: rgb("#9a3324"), accent: gold),
    card("knot-weave", color: rgb("#4d7b47"), accent: rgb("#9a3324")),
    card("knot-blocks", color: rgb("#1d2a44"), accent: gold),
    card("daisy", color: rgb("#4d7b47"), accent: rgb("#d9a441")),
    card("sakura", color: rgb("#4d7b47"), accent: rgb("#c4607a")),
    card("lotus", color: rgb("#1c7a78"), accent: rgb("#c4607a")),
    card("palmette", color: rgb("#2f628c"), accent: gold),
    card("ogee", color: blue, accent: gold),
    card("rinceau", color: rgb("#1c7a78"), accent: red),
    card("girih", color: rgb("#1c7a78"), accent: gold),
    card("hexastar", color: blue, accent: gold),
    card("strap", color: rgb("#1c7a78"), accent: rgb("#b07a1c")),
  )
}
