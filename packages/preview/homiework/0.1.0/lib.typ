#let homework(
  course: "COURSE 000",
  semester: "Spring 20XX",
  number: "X",
  author: "Tobias Follett",
  date: datetime.today(),
  doc,
) = {
  set text(font: "New Computer Modern")

  set document(
    title: course + " " + semester + " - Homework " + number,
    author: author,
    date: date,
  )

  set page(
    numbering: "1",
    header: context {
      if counter(page).get().first() > 1 [
        #set text(style: "italic")
        #course -- Homework #number
        #h(1fr)
        #author
        #block(line(length: 100%, stroke: 0.5pt), above: 0.6em)
      ]
    },
  )

  show raw.where(block: true): it => {
    align(center,
      block(
        width: 80%,
        radius: 4pt,
        fill: luma(235),
        inset: (x: 10pt, y: 8pt),
        align(left)[
          #show raw.line: l => context {
            box(
              width: measure([#it.lines.last().count]).width,
              align(right,
                text(fill: luma(150), size: 9pt)[#l.number]
              )
            )
            h(8pt)
            text(size: 9pt, l.body)
          }
          #it
        ]
      )
    )
  }

  align(center, {
    text(size: 16pt, weight: "bold")[#course #semester \ Homework #number]
    linebreak()
    text(size: 12pt)[#author]
    linebreak()
    emph[#date.display("[month repr:long] [day], [year]")]
    v(0.5em)
    line(length: 100%)
  })

  v(0.5em)
  doc
}