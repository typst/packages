// nibframe — a gallery of all the styles.
//   typst compile --root . examples/gallery.typ                  (français)
//   typst compile --root . --input lang=en examples/gallery.typ  (English)
#import "../lib.typ": *

#let lang = sys.inputs.at("lang", default: "fr")
#let T(fr, en) = if lang == "en" { en } else { fr }
#set text(font: "Libertinus Serif", size: 11pt, fill: rgb("#2b2622"), lang: lang)
#set page(paper: "a4", fill: rgb("#fbf7ee"))

#let ink = rgb("#2b2622")

// ── pages 1–3: every style on a small card
#let card(s, ..o) = align(center, stack(dir: ttb, spacing: 3pt,
  frame-graphic(112pt, 138pt, style: s, band: 6mm, inset: 2.5mm, paper: rgb("#fbf7ee"), ..o),
  text(size: 9pt, raw(s))))
#{
  set page(margin: 12mm)
  align(center, text(size: 24pt, weight: "bold")[nibframe])
  v(-2pt)
  align(center, text(size: 10pt, style: "italic")[#T("quarante styles — framed.with(style: …)", "forty styles — framed.with(style: …)")])
  v(6pt)
  grid(columns: (1fr,) * 4, row-gutter: 10pt,
    card("classic", color: rgb("#7a2e0e")),
    card("celtic"),
    card("braid"),
    card("chain"),
    card("arabesque"),
    card("islamic", color: rgb("#1c7a78"), accent: rgb("#b07a1c")),
    card("greek", color: rgb("#1d2a44"), accent: rgb("#9a3324")),
    card("scallop", color: rgb("#9a3324"), accent: rgb("#1d2a44")),
    card("deco", color: rgb("#1d2a44"), accent: rgb("#b07a1c")),
    card("braces", color: rgb("#1d2a44"), accent: rgb("#9a3324")),
    card("pearls", color: rgb("#4d7b47"), accent: rgb("#c9962c")),
    card("guilloche", color: rgb("#1c7a78"), accent: rgb("#9a3324")),
    card("banknote", color: rgb("#2f628c"), accent: rgb("#9a3324")),
  )
}
#pagebreak()
#{
  set page(margin: 12mm)
  let blue = rgb("#1d2a44")
  let red = rgb("#9a3324")
  grid(columns: (1fr,) * 4, row-gutter: 10pt,
    card("baroque", color: rgb("#1d3f5c"), accent: rgb("#b07a1c")),
    card("triquetra"),
    card("solomon", color: rgb("#6b2a5c"), accent: rgb("#c9962c")),
    card("zellige", color: rgb("#1c7a78"), accent: rgb("#b07a1c")),
    card("seigaiha", color: blue, accent: red),
    card("kilim", color: red, accent: blue),
    card("laurel", color: rgb("#4d7b47"), accent: rgb("#c9962c")),
    card("flowers", color: rgb("#2f628c"), accent: rgb("#c9962c")),
    card("stamp", color: red, accent: blue),
    card("film", color: rgb("#2b2622"), accent: rgb("#9a3324")),
    card("photo", color: rgb("#4a3b2f"), accent: rgb("#b07a1c")),
    card("neon", color: rgb("#c2185b"), accent: rgb("#1a8fc9")),
    card("illumination", color: rgb("#1d2a44"), accent: rgb("#b07a1c")),
  )
}
#pagebreak()
#{
  set page(margin: 12mm)
  align(center, text(size: 14pt, weight: "bold")[#T("Guillochés de sécurité — bill-…", "Security guilloché — bill-…")])
  v(6pt)
  let tones = (
    (rgb("#5d6b82"), rgb("#8c97ab")), (rgb("#2f6b4f"), rgb("#7aa58f")), (rgb("#7a2e3a"), rgb("#c48a93")), (rgb("#2f628c"), rgb("#b07a1c")),
    (rgb("#4a4a52"), rgb("#9a9aa6")), (rgb("#1c7a78"), rgb("#9a3324")), (rgb("#6b4a2a"), rgb("#b89a6a")), (rgb("#3b4a8c"), rgb("#8c6ab0")),
    (rgb("#2f6b4f"), rgb("#b07a1c")), (rgb("#7a2e3a"), rgb("#5d6b82")),
    (rgb("#3b8fb5"), rgb("#7cc0dc")), (rgb("#3b2f8c"), rgb("#c05aa0")), (rgb("#2a9d9a"), rgb("#6fc4c0")), (rgb("#5b3a8c"), rgb("#d07a2c")))
  let names = ("lens", "fan", "ribbon", "shell", "wave", "frill", "net", "swell", "plait", "rosette", "wavy", "diploma", "lattice", "weave")
  grid(columns: (1fr,) * 4, row-gutter: 10pt,
    ..names.enumerate().map(((i, n)) => card("bill-" + n, color: tones.at(i).at(0), accent: tones.at(i).at(1))))
}
