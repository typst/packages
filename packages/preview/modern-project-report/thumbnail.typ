#set page(width: 1200pt, height: 600pt, margin: 0pt, fill: rgb("#0f172a"))

// Title header
#place(top + left, dx: 60pt, dy: 45pt)[
  #text(32pt, weight: 900, fill: rgb("#f8fafc"))[Modern Project Report] #h(12pt)
  #box(
    fill: rgb("#2563eb"),
    inset: (x: 10pt, y: 6pt),
    radius: 4pt,
    text(14pt, weight: "bold", fill: white)[v0.1.0]
  ) \
  #v(6pt)
  #text(16pt, fill: rgb("#94a3b8"))[A clean, modern college & university project report template for Typst]
]

// Card 1: Cover Page
#place(top + left, dx: 120pt, dy: 150pt)[
  #block(
    width: 280pt,
    height: 396pt,
    stroke: 1.5pt + rgb("#334155"),
    radius: 8pt,
    clip: true,
    fill: white,
    image("page-1.png", width: 100%)
  )
]

// Card 2: TOC Page
#place(top + left, dx: 460pt, dy: 150pt)[
  #block(
    width: 280pt,
    height: 396pt,
    stroke: 1.5pt + rgb("#334155"),
    radius: 8pt,
    clip: true,
    fill: white,
    image("page-3.png", width: 100%)
  )
]

// Card 3: Body Content Page
#place(top + left, dx: 800pt, dy: 150pt)[
  #block(
    width: 280pt,
    height: 396pt,
    stroke: 1.5pt + rgb("#334155"),
    radius: 8pt,
    clip: true,
    fill: white,
    image("page-4.png", width: 100%)
  )
]
