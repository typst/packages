#import "@preview/scripst:1.1.3": braket, font, mycolor

#set page(
  width: 180mm,
  height: 240mm,
  margin: (x: 11mm, y: 9mm),
  fill: luma(248),
)
#set text(font: font.body, size: 9pt, fill: rgb("#252A29"))
#set par(leading: 0.55em)

#let ink = rgb("#252A29")
#let muted = rgb("#6D7471")
#let paper = white
#let border = luma(215)
#let teal = rgb("#187E78")
#let orange = rgb("#D67532")

#let tag(body, color: teal) = text(
  font: font.header,
  size: 7pt,
  weight: "bold",
  tracking: 0.08em,
  fill: color,
  body,
)

#let rounded(body, fill: paper, stroke: 0.65pt + border, inset: 8pt) = block(
  width: 100%,
  fill: fill,
  stroke: stroke,
  radius: 6pt,
  inset: inset,
  body,
)

#let advantage(number, title, body) = rounded(
  inset: (x: 8pt, y: 6pt),
  [
    #grid(
      columns: (10mm, 1fr),
      gutter: -10pt,
      [#text(font: "New Computer Modern", size: 12pt, fill: teal)[#number]],
      [
        #text(font: font.heading, size: 10.5pt, weight: "bold")[#title]
        #v(-3pt)
        #text(size: 9pt, fill: muted)[#body]
      ],
    )
  ],
)

#grid(
  columns: (1fr, auto),
  align: (left, top),
  [#tag([TYPST + SCRIPST])], [#text(size: 7pt, fill: orange)[github.com/An-314/scripst]],
)
#v(2pt)
#text(font: font.heading, size: 20pt, weight: "bold")[Why Typst + Scripst?]
#v(2pt)
#text(size: 8.6pt, fill: muted)[Write lightly. Typeset professionally. Keep your tools at the speed of thought.]

#v(3mm)

#grid(
  columns: (1fr, 1fr),
  gutter: 2.5mm,
  row-gutter: 2.5mm,
  advantage([01], [Light like Markdown], [Readable markup for headings, lists, and emphasis.]),
  advantage([02], [Typesets like LaTeX], [Equations, references, and pages for formal work.]),

  advantage([03], [Instant feedback], [Incremental compilation keeps every edit immediate.]),
  advantage([04], [Modern packages], [Pin versions in source; fetch and cache packages on demand.]),
)

#v(3mm)

#rounded(
  fill: ink,
  stroke: none,
  inset: 9pt,
  [
    #tag([SCRIPST ADDS THE SYSTEM], color: rgb("#EBA875"))
    #v(2pt)
    #text(font: font.heading, size: 13pt, weight: "bold", fill: white)[
      A mature toolkit for academic writing in Typst.
    ]
    #v(5pt)
    #grid(
      columns: (1fr, 1fr),
      gutter: 4pt,
      row-gutter: 4pt,
      rounded(fill: rgb("#FFFFFF12"), stroke: 0.5pt + rgb("#FFFFFF2F"), inset: 6pt, [#text(
          size: 12pt,
          weight: "bold",
          fill: white,
        )[Layout presets]#v(-4pt)#text(size: 10pt, fill: luma(215))[Articles, reports, and books, ready to use.]]),
      rounded(fill: rgb("#FFFFFF12"), stroke: 0.5pt + rgb("#FFFFFF2F"), inset: 6pt, [#text(
          size: 12pt,
          weight: "bold",
          fill: white,
        )[Parameters]#v(-4pt)#text(size: 10pt, fill: luma(215))[Tune fonts, spacing, outlines, and links.]]),

      rounded(fill: rgb("#FFFFFF12"), stroke: 0.5pt + rgb("#FFFFFF2F"), inset: 6pt, [#text(
          size: 12pt,
          weight: "bold",
          fill: white,
        )[Content blocks]#v(-4pt)#text(size: 10pt, fill: luma(215))[Definitions, theorems, problems, and solutions.]]),
      rounded(fill: rgb("#FFFFFF12"), stroke: 0.5pt + rgb("#FFFFFF2F"), inset: 6pt, [#text(
          size: 11pt,
          weight: "bold",
          fill: white,
        )[Ratchet]#v(-3pt)#text(size: 10pt, fill: luma(215))[Consistent numbering, resets, and references.]]),
    )
  ],
)

#v(3mm)

#rounded(
  inset: 8pt,
  [
    #tag([FORMULA LANGUAGE])
    #v(3pt)
    #text(size: 10pt, weight: "bold", fill: muted)[LaTeX]
    #v(1pt)
    #text(size: 9pt)[#raw("\\langle A\\rangle_\\psi=\\int \\psi^*(x)\\hat A\\psi(x)\\,\\mathrm{d}x")]
    #v(3pt)
    #text(size: 10pt, weight: "bold", fill: teal)[Typst]
    #v(1pt)
    #text(size: 9pt)[#raw("braket(Psi, hat(A), Psi) = integral Psi^*(x) hat(A) Psi(x) dif x")]
    #v(4pt)
    #align(center)[#text(
      font: "New Computer Modern Math",
      size: 10.5pt,
    )[$braket(Psi, hat(A), Psi) = integral Psi^*(x) hat(A) Psi(x) dif x$]]
  ],
)

#v(3mm)

#rounded(
  fill: mycolor.orange.transparentize(82%),
  stroke: 0.65pt + mycolor.orange,
  inset: 8pt,
  [
    #tag([CLASSROOM NOTE TEST], color: orange)
    #v(2pt)
    #text(
      font: font.countblock,
      size: 10pt,
      weight: "bold",
    )[
      "Write and preview fast enough to keep up with class."
    ]
    #v(2pt)
    #text(size: 9pt, fill: muted)[Less boilerplate keeps your attention on the mathematics.]
  ],
)

#place(bottom + right, dy: 6mm)[
  #text(size: 8pt, fill: muted)[Less boilerplate. More of the actual work.]
]
