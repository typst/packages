// Presets: the kinds of paper the letters are cut from (palettes) and the
// typefaces they are printed in (faces).

// ==========================================================================
// Palettes
//
// A palette is an array of *scraps*. Each scrap says what the paper looks like
// (`fill`, any Typst paint), what colour the printed letter is (`ink`) and how
// often it turns up (`weight`).

/// Creates one kind of paper scrap. Use it to build your own palettes.
#let scrap(fill, ink, weight: 1) = (fill: fill, ink: ink, weight: weight)

#let _dots(base, dot) = tiling(size: (3pt, 3pt), relative: "self")[
  #rect(width: 100%, height: 100%, fill: base, stroke: none)
  #place(center + horizon, circle(radius: 0.6pt, fill: dot, stroke: none))
]

#let _stripes(base, stripe) = tiling(size: (4pt, 4pt), relative: "self")[
  #rect(width: 100%, height: 100%, fill: base, stroke: none)
  #place(left, rect(width: 0.7pt, height: 100%, fill: stripe, stroke: none))
]

#let _black = rgb("#1a1a1a")
#let _cream = rgb("#f6f1e2")

/// Ready-made palettes, selectable by name.
#let palettes = (
  // Newsprint, glossy ads and colourful headlines.
  classic: (
    scrap(rgb("#efe5cb"), _black, weight: 4),
    scrap(rgb("#fbfaf5"), _black, weight: 3),
    scrap(rgb("#cfcbc0"), _black, weight: 1.5),
    scrap(_black, _cream, weight: 2),
    scrap(rgb("#c8202f"), _cream, weight: 2),
    scrap(rgb("#f4c430"), _black, weight: 2),
    scrap(rgb("#1f4e9c"), _cream, weight: 1.5),
    scrap(_dots(rgb("#f6d9e0"), rgb("#d6336c")), _black),
    scrap(_stripes(rgb("#efe5cb"), rgb("#b9ae8d")), _black),
  ),
  // Strictly black and white, like a photocopied newspaper.
  noir: (
    scrap(rgb("#fbfaf6"), _black, weight: 4),
    scrap(rgb("#e4e1d8"), _black, weight: 2),
    scrap(_black, rgb("#fbfaf6"), weight: 3),
    scrap(_stripes(rgb("#fbfaf6"), rgb("#c7c3b8")), _black),
  ),
  // Soft pastels, for a *friendly* ransom note.
  candy: (
    scrap(rgb("#f7b6c8"), rgb("#2b2b3a")),
    scrap(rgb("#b8e6c9"), rgb("#2b2b3a")),
    scrap(rgb("#fff0a8"), rgb("#2b2b3a")),
    scrap(rgb("#b8d8f5"), rgb("#2b2b3a")),
    scrap(rgb("#d9c6f2"), rgb("#2b2b3a")),
    scrap(rgb("#2b2b3a"), rgb("#fff0a8"), weight: 0.7),
  ),
  // Faded paper from an old attic.
  vintage: (
    scrap(rgb("#e6d3a3"), rgb("#2f2417"), weight: 3),
    scrap(rgb("#d9c08a"), rgb("#2f2417"), weight: 2),
    scrap(rgb("#f1e4c3"), rgb("#2f2417"), weight: 3),
    scrap(rgb("#b5553a"), rgb("#f1e4c3"), weight: 1.5),
    scrap(rgb("#2f4858"), rgb("#f1e4c3"), weight: 1.5),
    scrap(_stripes(rgb("#e6d3a3"), rgb("#bda76f")), rgb("#2f2417")),
  ),
)

// ==========================================================================
// Faces
//
// A face is a dictionary with a `font` (a name or a fallback list, exactly as
// `text(font: ..)` accepts), a `weight` and a `style`.

/// Creates one typeface entry. Use it to build your own `faces` array.
#let face(font, weight: "regular", style: "normal") = (
  font: font,
  weight: weight,
  style: style,
)

/// Ready-made face sets, selectable by name.
#let faces = (
  // Only fonts that ship with Typst itself, so the result looks the same on
  // every machine and in the web app, and no font warnings can appear.
  embedded: (
    face("Libertinus Serif"),
    face("Libertinus Serif", weight: "bold"),
    face("Libertinus Serif", style: "italic"),
    face("Libertinus Serif", weight: "bold", style: "italic"),
    face("New Computer Modern"),
    face("New Computer Modern", weight: "bold"),
    face("New Computer Modern", style: "italic"),
    face("DejaVu Sans Mono"),
    face("DejaVu Sans Mono", weight: "bold"),
  ),
  // A louder mix that leans on fonts found on most Windows and macOS systems.
  // Each entry falls back to an embedded font, but Typst prints a warning for
  // every family it cannot find, so this one is opt-in.
  expressive: (
    face(("Impact", "Libertinus Serif"), weight: "bold"),
    face(("Arial Black", "DejaVu Sans Mono"), weight: "bold"),
    face(("Georgia", "Libertinus Serif"), weight: "bold"),
    face(("Georgia", "Libertinus Serif"), style: "italic"),
    face(("Courier New", "DejaVu Sans Mono"), weight: "bold"),
    face(("Times New Roman", "New Computer Modern")),
    face(("Trebuchet MS", "Libertinus Serif"), weight: "bold"),
    face(("Verdana", "DejaVu Sans Mono")),
    face(("Comic Sans MS", "Libertinus Serif"), weight: "bold"),
  ),
)
