// nibframe — background textures and seal (options `texture:` and `seal:`).
//   typst compile --root . examples/textures.typ                  (français)
//   typst compile --root . --input lang=en examples/textures.typ  (English)
#import "../lib.typ": *

#let lang = sys.inputs.at("lang", default: "fr")
#let T(fr, en) = if lang == "en" { en } else { fr }
#set text(font: "Libertinus Serif", size: 11pt, fill: rgb("#2b2622"), lang: lang)
#set page(paper: "a4", fill: rgb("#fbf7ee"))

#{
  set page(margin: 12mm)
  align(center, text(size: 14pt, weight: "bold")[#T("Textures de fond et sceau", "Background textures and seal")])
  v(6pt)
  let big(s, o, cap) = align(center, stack(dir: ttb, spacing: 4pt, frame-graphic(150pt, 210pt, style: s, inset: 3mm, paper: rgb("#fbf7ee"), ..o), text(size: 8pt, raw(cap))))
  grid(columns: (1fr,) * 3, row-gutter: 14pt,
    big("bill-wavy", (color: rgb("#3b8fb5"), accent: rgb("#7cc0dc"), texture: "scales", seal: true), "bill-wavy + scales + seal"),
    big("bill-diploma", (color: rgb("#3b2f8c"), accent: rgb("#c05aa0"), texture: "waves", seal: true), "bill-diploma + waves + seal"),
    big("bill-lattice", (color: rgb("#2a9d9a"), accent: rgb("#6fc4c0"), texture: "rosettes"), "bill-lattice + rosettes"),
    big("celtic", (texture: "rosettes", seal: true), "celtic + rosettes + seal"),
    big("bill-weave", (color: rgb("#5b3a8c"), accent: rgb("#d07a2c"), texture: "waves", corners: false), "bill-weave + waves, corners: false"),
    big("arabesque", (texture: "scales"), "arabesque + scales"),
  )
}
