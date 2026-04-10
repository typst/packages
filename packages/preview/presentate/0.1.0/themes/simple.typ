#import "../presentate.typ" as p
#import "../store.typ": *

#let current-section = context {
  query(heading.where(level: 1).before(here())).at(-1, default: box[]).body
}

#let current-heading = context {
  query(heading.where(level: 2).before(here()))
    .filter(h => {
      counter(heading).get().at(0) == counter(heading).at(h.location()).at(0)
    })
    .at(-1, default: [])
  if heading.numbering != none {
    alias-counter("heading").update((..n) => {
      n = n.pos()
      n.at(1) -= 1
      n
    })
  }
}

#let empty-slide(..args) = {
  set page(margin: 0pt, header: none, footer: none)
  p.slide(..args)
}


#let slide(..args, align: top) = {
  let kwargs = args.named()
  let args = args.pos()
  let title
  let body

  if args.len() == 1 {
    body = args
    title = current-heading
  } else if args.at(0) == auto {
    (_, ..body) = args
    title = current-heading
  } else if args.len() >= 2 {
    (title, ..body) = args
    title = heading(level: 2, title)
  }

  p.slide(
    ..kwargs,
    [
      #title
      #set std.align(align)
      #grid(columns: (1fr,) * body.len(), ..body, gutter: 1em)
    ],
  )
}

#let focus-slide(..args, fill: eastern, body) = {
  empty-slide(
    ..args,
    {
      set page(fill: fill)
      set text(fill: white)
      body
    },
  )
}

#let template(
  body,
  header: auto,
  footer: auto,
  author: [Author Name],
  title: [Title of Presentation],
  subtitle: [Some description of the presentation.],
  date: datetime.today().display(),
  enable-section-slide: true,
  aspect-ratio: "16-9",
  ..options,
) = {
  if header == auto {
    header = {
      set text(fill: gray, size: 0.8em)
      current-section
    }
  }

  if footer == auto {
    footer = {
      set text(fill: gray, size: 0.8em)
      author
      h(1fr)
      context counter(page).display("1")
    }
  }

  set page(paper: "presentation-" + aspect-ratio, header: header, footer: footer)
  set text(size: 20pt, font: "Lato")
  show math.equation: set text(font: "Lete Sans Math")

  empty-slide(
    logical-slide: false,
    {
      set align(center + horizon)
      text(size: 2em, weight: "bold", title)
      v(-1em)
      emph(subtitle)
      linebreak()
      grid(columns: 2, author, grid.vline(), date, inset: (x: 0.5em))
    },
  )

  show heading.where(level: 1): h => {
    focus-slide(
      logical-slide: false,
      {
        set align(center + horizon)
        set text(size: 1.5em, weight: "bold")
        h
      },
    )
  }

  show heading.where(level: 2): set text(size: 1.5em)
  show emph: set text(fill: eastern)

  set-options(..options)

  body
}
