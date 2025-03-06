#import "style/theme.typ": book-theme
#import "templates/book.typ": book-template

#let dnd-note-fold = (
  top-left: polygon(
    fill: luma(0%),
    (0%, 100% - 0.75pt),
    (100%, 0%),
    (100%, 100%),
  ),
  top-right: polygon(
    fill: luma(0%),
    (0%, 0%),
    (100%, 100% - 0.75pt),
    (0%, 100%),
  ),
  bottom-left: polygon(
    fill: luma(0%),
    (0%, 0.75pt),
    (100%, 0%),
    (100%, 100%),
  ),
  bottom-right: polygon(
    fill: luma(0%),
    (0%, 0%),
    (100%, 0.75pt),
    (0%, 100%),
  ),
)

#let dnd-with-folds = body => block(
  breakable: false,
  align(left)[
    #block(
      below: 0pt,
      breakable: false,
    )[
      #box(
        width: 3mm,
        height: 1mm,
        dnd-note-fold.top-left,
      )
      #h(1fr)
      #box(
        width: 3mm,
        height: 1mm,
        dnd-note-fold.top-right,
      )
    ]
    #body
    #block(
      above: 0pt,
      breakable: false,
    )[
      #box(
        width: 3mm,
        height: 1mm,
        dnd-note-fold.bottom-left,
      )
      #h(1fr)
      #box(
        width: 3mm,
        height: 1mm,
        dnd-note-fold.bottom-right,
      )
    ]
  ],
)

#let dnd-note = (body, theme: book-theme()) => {
  set par(justify: true)

  set text(font: theme.font.aside)

  set heading(
    level: 10,
    outlined: false,
  )

  show heading: smallcaps
  show heading: set text(
    size: 14pt,
    weight: 500,
    font: theme.font.aside,
    fill: luma(0%),
  )

  place(
    auto,
    float: true,
    dnd-with-folds(
      block(
        width: 100%,
        fill: rgb(235, 214, 193),
        stroke: (
          y: (
            paint: luma(0%),
            thickness: 1.5pt,
          ),
        ),
        inset: 8pt,
        breakable: false,
        body,
      ),
    ),
  )
}

#let dnd-dialogue = (..lines, highlight: (), theme: book-theme()) => {
  set text(font: theme.font.aside)

  show <dnd-dm>: set text(fill: theme.paint.label.dm.fill)

  show <dnd-player>: set text(fill: theme.paint.label.player.fill)

  show terms: it => block(
    fill: theme.paint.dialogue.fill,
    inset: 3mm,
    it,
  )

  lines = lines.pos().map(((speaker, line)) => {
    if speaker in highlight {
      ([#text(speaker + ":") <dnd-dm>], line)
    } else {
      ([#text(speaker + ":") <dnd-player>], line)
    }
  })

  terms(..lines)
}

#let dnd-enum = (..items, cols: 2, theme: book-theme()) => {
  set text(font: theme.font.aside)

  let items = items.pos().map(item => par(item))
  let count = items.len()
  let rows = calc.div-euclid(count, cols)

  items = items
    .chunks(rows)
    .map(chunk => {
        (..chunk, colbreak())
      })
    .join()

  block(inset: (x: 1cm), columns(cols, items.join()))
}

#let dnd-terms = (..args) => {
  let t = args.pos().map(((term, desc)) => {
    (emph(term + "."), desc)
  })

  terms(..t)
}