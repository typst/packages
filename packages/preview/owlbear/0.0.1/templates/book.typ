#import "@preview/droplet:0.3.1": dropcap

#import "../style/theme.typ": book-theme

#let chapter_style = (
  chapters: true,
) => if chapters {
  return (body) => {
    set heading(
      numbering: "1",
    )

    set par(
      leading: 0pt,
      spacing: 16pt,
    )

    show heading: (it) => {
      let n = context(counter(<chapter_number>).display("1"))
      return align(center)[
        #text[Chapter #n] <chapter_number>
        #it.body
      ]
    }

    body
  }
} else { return (body) => body }

#let book-template = (
  body,
  chapters: false,
  dropcaps: true,
  theme: book-theme(),
) => {
  set page(
    paper: "a4",
    margin: 1.7cm,
  )

  set par(
    justify: true
  )

  set text(
    font: theme.font.body,
    size: 11pt,
    ligatures: true,
    discretionary-ligatures: true,
  )

  show heading: set text(
    font: theme.font.heading,
    fill: theme.paint.heading.fill,
    weight: 400,
  )

  show heading.where(level: 1): set text(
    size: 34pt,
    fill: theme.paint.chapter.heading.fill,
    stroke: (
      paint: theme.paint.chapter.heading.stroke,
      thickness: 1pt,
    ),
    weight: 300,
  )

  show heading.where(level: 1): chapter_style(chapters: chapters)

  show heading.where(level: 2): set text(
    size: 18pt,
  )

  show heading.where(level: 3): set text(
    size: 14pt
  )
  show heading.where(level: 3): block.with(
    width: 100%,
    inset: (
      bottom: 5pt,
    ),
    stroke: (
      bottom: (
        paint: theme.paint.heading.line,
        thickness: 1pt,
      )
    ),
  )

  let paragraph_counter = counter("paragraph")

  show <chapter_number>: upper
  show <chapter_number>: align.with(center)
  show <chapter_number>: set text(
    font: theme.font.heading,
    number-type: "lining",
    size: 14pt,
    weight: 600,
    fill: theme.paint.chapter.number.fill,
  )
  show <chapter_number>: {
    paragraph_counter.step()
  }

  set table(
    fill: (x, y) => if y == 0 {
      return none
    } else if calc.rem(y, 2) == 0 {
      return theme.paint.table.even
    } else {
      return theme.paint.table.odd
    },
    stroke: none,
  )

  show table: set text(
    font: theme.font.table,
  )

  show table.cell: it => {
    if it.y == 0 {
      strong(it)
    } else {
      it
    }
  }

  show figure.where(
    kind: table
  ): set figure.caption(
    position: top
  )

  show figure.where(
    kind: table
  ): it => {
    show figure.caption: set text(
      font: theme.font.table,
      size: 14pt,
      weight: 500,
    )
    show figure.caption: smallcaps

    align(left)[#it]
  }

  show figure.where(
    kind: table
  ): set figure(
    numbering: none,
  )

  show par: (it) => {
    paragraph_counter.step(level: 2)
  
    context {
      if paragraph_counter.get().at(1) == 1 {
        return dropcap(
          height: 3,
          font: theme.font.dropcap,
          fill: theme.paint.dropcap.fill,
          stroke: (
            paint: theme.paint.dropcap.stroke,
            thickness: 1.5pt,
          ),
          it.body
        )
      } else {
        return it
      }
    }
  }

  body
}