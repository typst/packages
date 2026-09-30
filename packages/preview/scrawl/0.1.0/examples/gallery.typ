// L'image d'en-tête du README : une seule scène, tout le vocabulaire.
//
// Ce n'est pas un extrait du showcase — celui-ci montre chaque trait
// séparément, avec son code. Ici tout est réuni en une image : c'est ce
// qu'on regarde avant de lire quoi que ce soit.
//
//     typst compile --root . examples/gallery.typ examples/gallery.png --ppi 140
#import "@preview/scrawl:0.1.0": *
#set page(width: 17cm, height: auto, margin: 8mm, fill: white)
#set text(font: ("Libertinus Serif", "DejaVu Serif"), size: 9.5pt)

#align(center)[
  #text(size: 19pt, weight: "bold")[scrawl]
  #v(-8pt)
  #text(size: 13pt, fill: rgb("#444"))[#emoji.hand.write FERGOUS Abdelhak]
  #v(-8pt)
  #text(size: 9.5pt, fill: rgb("#555"))[
    hand-drawn shapes in plain Typst — no plugin, no dependency
  ]
]

#v(-1mm)

#scrawl(width: 15.4cm, height: 8.6cm, roughness: 1.05,
        (shape, lines, region, rough, label, arrow) => {
  // ---- une courbe annotée, façon tableau noir
  arrow((0.5, 4.9), (7.0, 4.9), weight: 1.2pt)
  arrow((0.5, 4.9), (0.5, 8.3), weight: 1.2pt)
  shape(((0.7, 5.1), (1.8, 5.35), (2.7, 5.8), (3.6, 6.7),
         (4.7, 7.2), (5.6, 7.4), (6.5, 7.45)),
    paint: rgb("#2B6CB0"), weight: 1.7pt, closed: false)
  label((3.6, 4.45), text(8pt)[temps passé à peaufiner])
  label((0.32, 8.3), text(8pt)[qualité], anchor: right + horizon)
  label((4.6, 8.35), text(7.5pt, fill: rgb("#C2410C"))[le palier])
  arrow((5.3, 8.15), (6.2, 7.65), bend: 0.18,
    paint: rgb("#C2410C"), weight: 0.8pt)

  // ---- des barres hachurées
  let data = ((1.5, rgb("#2B6CB0")), (2.4, rgb("#C2410C")),
              (1.0, rgb("#166534")), (2.8, rgb("#7C3ABA")))
  for (i, (h, col)) in data.enumerate() {
    let x = 8.3 + i * 1.05
    shape(rect-pts((x, 5.1), (x + 0.72, 5.1 + h)),
      paint: col, weight: 1.1pt, seed: 11 + i * 7,
      fill: hatching(col, gap: 0.15, angle: 60deg))
  }
  arrow((8.0, 5.1), (12.9, 5.1), weight: 1.1pt)
  label((10.4, 8.35), text(8pt)[`fill: hatching(..)`])

  // ---- un camembert
  let parts = ((42%, rgb("#2B6CB0")), (28%, rgb("#C2410C")),
               (18%, rgb("#166534")), (12%, rgb("#B45309")))
  let a = 90.0
  for (i, (f, col)) in parts.enumerate() {
    let b = a - f / 100% * 360
    shape(arc-pts((1.7, 1.9), 1.35, a, b, n: 24) + ((1.7, 1.9),),
      paint: col, weight: 1.1pt, seed: 3 + i * 9,
      fill: hatching(col, gap: 0.16, angle: (a - 45) * 1deg))
    a = b
  }

  // ---- un schéma relié
  let boite(x, y, w, h, txt, col) = {
    shape(rounded-rect-pts((x, y), (x + w, y + h), radius: 0.2),
      paint: col, fill: col.lighten(84%), weight: 1.1pt)
    label((x + w / 2, y + h / 2), text(8pt, txt))
  }
  boite(4.0, 2.5, 1.9, 0.85, [écrire], rgb("#2B6CB0"))
  boite(6.4, 2.5, 1.9, 0.85, [relire], rgb("#C2410C"))
  boite(8.8, 2.5, 1.9, 0.85, [publier], rgb("#166534"))
  arrow((6.0, 2.92), (6.3, 2.92), weight: 1pt)
  arrow((8.4, 2.92), (8.7, 2.92), weight: 1pt)
  arrow((7.4, 2.4), (5.0, 2.4), bend: 0.22, weight: 0.9pt)
  label((6.2, 1.55), text(7.5pt, fill: rgb("#666"))[ça ne va pas])

  // ---- des bonshommes allumettes et leur bulle
  let gus(x, y, col: black, bras: (35deg, 145deg),
          jambes: (250deg, 290deg)) = {
    let trait(p, q) = shape((p, q), paint: col, closed: false,
      weight: 1.1pt)
    shape(circle-pts((x, y), 0.28, n: 24), paint: col, weight: 1.1pt)
    trait((x, y - 0.28), (x, y - 1.05))
    for t in bras {
      trait((x, y - 0.45), (x + 0.5 * calc.cos(t),
                            y - 0.45 + 0.5 * calc.sin(t)))
    }
    for t in jambes {
      trait((x, y - 1.05), (x + 0.58 * calc.cos(t),
                            y - 1.05 + 0.58 * calc.sin(t)))
    }
  }
  gus(11.6, 1.9)
  gus(12.7, 1.9, col: rgb("#2B6CB0"), bras: (70deg, 150deg))
  shape(rounded-rect-pts((13.4, 1.5), (15.3, 2.6), radius: 0.25),
    paint: black, fill: white, weight: 1.1pt)
  shape(((13.8, 1.55), (13.3, 1.0), (14.3, 1.55)),
    paint: black, fill: white, weight: 1.1pt)
  label((14.35, 2.05), text(8pt)[ça compile !])
})

#v(-2mm)

#align(center, text(size: 8.5pt, fill: rgb("#666"))[
  `scrawl-box` · `scrawl-ellipse` · `scrawl-underline` · `hl` — et un canevas
  en centimètres, y vers le haut, avec `shape`, `label`, `arrow` et `hatching`.
])
