#let translate(de, en) = context if text.lang == "de" { de } else { en }

#let homework(
  names: [],
  course: [],
  tutorium: [],
  week: 1,
  language: "de",
  type: translate("Hausaufgabe", "Homework"),
  semester: auto,
  body,
) = {
  assert(language in ("de", "en"), message: "Choose either de or en.")
  set text(lang: language, size: 12pt)
  set enum(numbering: "1.")
  set page(
    paper: "a4",
    margin: (top: 15mm, inside: 1in, outside: 1in, bottom: 25mm),
    header: context {
      if here().page() > 1 {
        grid(
          columns: (1fr, 1fr),
          [#names], align(right)[#course #type],
        )
        line(length: 100%)
      }
    },
    footer: context {
      if here().page() > 1 {
        align(center, counter(page).display("1"))
      }
    },
  )

  if semester == auto or semester == "" {
    let today = datetime.today()
    let year = today.year()
    let month = today.month()
    semester = if month >= 4 and month < 10 {
      [#translate("Sommersemester", "Summer semester") #year]
    } else {
      let start = if month < 4 { year - 1 } else { year }
      let end = str(start + 1).slice(-2)
      [#translate("Wintersemester", "Winter semester") #start/#end]
    }
  }

  block(width: 100%, stroke: 0.6pt, inset: 8pt, below: 1.5em)[
    #grid(
      columns: (1fr, 1fr),
      row-gutter: 10pt,
      [#names],
      align(right)[#course],
      grid.cell(colspan: 2, inset: 8pt, align: center)[
        #text(size: 16pt, weight: "bold")[#type #translate("Woche", "Week") #week]
      ],
      [#translate("Tutorium", "Tutorial"): #tutorium],
      align(right)[#semester],
    )
  ]

  body
}

#let exercise(body, title: none, numbered: true) = block(
  width: 100%,
  above: 2em,
  below: 1em,
)[
  #let number = if numbered {
    let count = counter("linden-hpi.exercise")
    count.step()
    [ #context count.display("1")]
  }
  #let caption = if title != none [ (#title)]
  #strong[#translate("Aufgabe", "Exercise")#number#caption:]
  #v(0.4em)
  #pad(left: 1.5em, body)
]

#let solution(body) = block(
  width: 100%,
  above: 2em,
  below: 1em,
)[
  *#translate("Lösung", "Solution"):*
  #v(0.4em)
  #pad(left: 1.5em, body)
]
