#import "@preview/scrutinize:0.1.0": grading, question, questions
// #import "@local/scrutinize:0.1.0": grading, question, questions
// #import "../src/lib.typ" as scrutinize: grading, question, questions
#import question: q

// make the PDF reproducible to ease version control
#set document(date: none)

#let title = "Praktische Leistungsfeststellung"

#set document(title: title)
#set text(lang: "de")

#set page(
  paper: "a4",
  margin: (x: 1.5cm, y: 2cm, top: 4cm),
  header-ascent: 20%,
  // header: locate(loc => {
  //   if (calc.odd(loc.page())) {
  //   }
  // }),
  header: {
    set text(size: 10pt)

    table(
      columns: (1fr,) * 3,
      stroke: none,
      align: (col, row) => (left, center, left).at(col) + horizon,

      [],
      [*#title*],
      [],

      [Name:],
      [],
      [Datum: ],
    )
  },
)

#set table(stroke: 0.5pt)

#show heading.where(level: 2): it => {
  question.current(q => {
    [Frage #question.counter.display()]
    if it.body != [] {
      [: #it.body]
    }
    if q.points != none {
      [#h(1fr) #none / #q.points P.]
    }
    if q.category != none and "ek" in q.category {
      [ EK]
    }
  })
}

#question.all(qs => {
  set text(size: 10pt)

  let category-points(category) = grading.total-points(qs, filter: q => q.category == category)

  let mt = (category-points("gk-mt"), category-points("ek-mt"))
  let sock = (category-points("gk-sock"), category-points("ek-sock"))
  let total = grading.total-points(qs)

  let grades = grading.grades(
    [Nicht Genügend (5)],
    4/8 * total,
    [Genügend (4)],
    5/8 * total,
    [Befriedigend (3)],
    6/8 * total,
    [Gut (2)],
    7/8 * total,
    [Sehr Gut (1)],
  )

  let grades = grades.map(((body, lower-limit, upper-limit)) => {
    if lower-limit == none {
      (body: body, range: [< #upper-limit P.])
    } else if upper-limit != none {
      (body: body, range: [#(lower-limit + 0.5) - #upper-limit P.])
    } else {
      (body: body, range: [#(lower-limit + 0.5) - #total P.])
    }
  })

  [
    = Punkte nach Kompetenzbereichen

    #table(
      columns: (3fr, ..(1fr,) * 3),
      align: (col, row) =>
        if col == 0 { left + horizon }
        else { right + horizon },

      [*Kompetenzbereich*], [*Punkte GK*], [*Punkte EK*], [*Punkte Gesamt*],
      [Anwendungsentwicklung -- Multithreading], ..(..mt, mt.sum()).map(m => [#none / #m]),
      [Anwendungsentwicklung -- Sockets], ..(..sock, sock.sum()).map(m => [#none / #m]),
      [Gesamt], [], [], [#none / #total],
    )

    = Notenschlüssel

    #table(
      columns: (auto, ..(1fr,) * grades.len()),
      align: (col, row) =>
        if col == 0 { left + horizon }
        else { center + horizon },

      [Punkte:],
      ..grades.map(g => g.range),

      [Note:],
      ..grades.map(g => g.body),
    )
  ]
})

= Grundkompetenzen -- Theorieteil Multithreading

#lorem(50)

#q(category: "gk-mt", points: 2)[
  ==

  #lorem(40)
]

#q(category: "gk-mt", points: 2)[
  ==

  #lorem(40)
]

#q(category: "gk-mt", points:2)[
  ==

  #lorem(40)
]

#q(category: "gk-mt", points:3)[
  ==

  #lorem(40)
]

= Grundkompetenzen -- Theorieteil Sockets

#lorem(50)

#q(category: "gk-sock", points:6)[
  ==

  #lorem(50)
]

#q(category: "gk-sock", points:2)[
  ==

  #lorem(30)
]

= Grund- und erweiterte Kompetenzen -- Praktischer Teil Multithreading

#lorem(80)

#q(category: "gk-mt", points:4)[
  ==

  #lorem(40)
]

#q(category: "gk-mt", points:3)[
  ==

  #lorem(40)
]

#q(category: "gk-mt", points:4)[
  ==

  #lorem(40)
]

#q(category: "gk-mt", points:4)[
  ==

  #lorem(40)
]

#q(category: "ek-mt", points:5)[
  ==

  #lorem(40)
]

#q(category: "ek-mt", points:3)[
  ==

  #lorem(40)
]

= Grund- und erweiterte Kompetenzen -- Praktischer Teil Sockets

#lorem(80)

#q(category: "gk-sock", points:6)[
  ==

  #lorem(40)
]

#q(category: "gk-sock", points:4)[
  ==

  #lorem(40)
]

#q(category: "gk-sock", points:6)[
  ==

  #lorem(40)
]

#q(category: "ek-sock", points:3)[
  ==

  #lorem(40)
]

#q(category: "ek-sock", points:5)[
  ==

  #lorem(40)
]
