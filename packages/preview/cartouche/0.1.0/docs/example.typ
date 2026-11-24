// A short, complete document using cartouche: a dedication page, a chapter
// opening, and a floating section epigraph. Rendered to example.png for the
// README by `just docs`.
#import "@preview/cartouche:0.1.0": epigraph

#set page(width: 12cm, height: 18cm, margin: (x: 2cm, y: 2.2cm))
#set text(font: "Libertinus Serif", size: 10pt, lang: "en")
#set par(justify: true, first-line-indent: 1.2em, leading: 0.68em)
#show heading.where(level: 1): it => block(below: 1.3em, text(size: 1.4em, weight: "regular", it.body))
#show heading.where(level: 2): it => block(below: 1em, text(size: 1.1em, weight: "regular", it.body))

// Front matter: pinned to the middle of an otherwise empty page.
#epigraph(style: "dedication", position: horizon + center, by: "Heraclitus")[
  Everything flows, and nothing stays.
]

#pagebreak()

// Chapter opening: the classic epigraph, set under the heading.
= I. The River

#epigraph(by: "Henry David Thoreau", from: "Walden")[
  Time is but the stream I go a-fishing in.
]

#lorem(85)

// A pull quote, breaking up the running text.
#epigraph(style: "bar", by: "Marcus Aurelius", from: "Meditations")[
  The universe is change; our life is what our thoughts make it.
]

#lorem(55)

#pagebreak()

// A floating epigraph rides above the text instead of overlapping it.
#epigraph(style: "ruled", position: top, float: true, by: "Emily Dickinson")[
  Tell all the truth but tell it slant — Success in Circuit lies.
]

== II. The Slant

#lorem(75)

#epigraph(style: "marked", by: "Michel de Montaigne", from: "Essays")[
  I quote others only the better to express myself.
]

#lorem(35)

#pagebreak()

// Pinned to the corners of the text block. A pinned epigraph overlaps
// whatever is around it, so leave room for it.
#epigraph(position: top + start, width: 38%, by: "Blaise Pascal")[
  The heart has its reasons which reason knows nothing of.
]
#epigraph(position: top + end, width: 38%, by: "Francis Bacon")[
  Some books are to be tasted, others to be swallowed.
]

#v(2.6cm)

== III. The Corners

#lorem(55)

#epigraph(style: "ruled", position: bottom + center, by: "Seneca")[
  We suffer more often in imagination than in reality.
]

#pagebreak()

// Against the paper rather than the text block: in the margins, above and
// below everything else.
#epigraph(
  position: top,
  anchor: "page",
  dy: 1.1cm,
  style: "plain",
  width: auto,
  by: "Lao Tzu",
)[
  A journey of a thousand miles begins with a single step.
]

#epigraph(
  position: bottom,
  anchor: "page",
  dy: -1.1cm,
  style: "plain",
  width: auto,
  by: "William Blake",
)[
  To see a world in a grain of sand.
]

== IV. The Margins

#lorem(70)
