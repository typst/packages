#import "../presentate.typ" as p
#import "../store.typ": *

//#let used-lbl = label(prefix + "_used-headings") // prevent query loops

#let save-headings = state(prefix + "_headings")

#let current-section() = {
  query(heading.where(level: 1).before(here())).at(-1, default: box[]).body
}

#let current-heading() = {
  context {
    let hs = save-headings.get() 
    if hs != () and hs.last().level == 2 {
      hs.last()
    }
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
    (body,) = args
    title = current-heading()
  } else if args.at(0) == none {
    (_, body) = args
    title = none
  } else if args.len() == 2 {
    (title, body) = args
    title = heading(level: 2, title)
  }
  context save-headings.update(query(selector.or(heading.where(level: 1, outlined: true), heading.where(level: 2, outlined: true)).before(here())))
  p.slide(
    ..kwargs,
    [
      
      #show heading.where(level: 2): block.with(inset: (bottom: 0.65em), stroke: (bottom: 2pt + eastern))
      #title
      #set std.align(align)
      #body
    ],
  )
}

#let focus-slide(..args, fill: eastern, body) = {
  set page(fill: fill)
  empty-slide(
    ..args,
    {
      set align(center + horizon)
      show: emph
      set text(fill: white, size: 1.5em)
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
      context current-section()
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
      block(
        text(size: 2em, weight: "bold", title),
        inset: (bottom: 1.2em),
        stroke: (bottom: 2pt + eastern),
      )
      //v(-1em)
      emph(subtitle)
      linebreak()
      grid(
        columns: 2,
        author, grid.vline(), date,
        inset: (x: 0.5em),
      )
    },
  )

  show heading.where(level: 1): h => {
    set page(fill: eastern)
    empty-slide(
      logical-slide: false,
      {
        set align(center + horizon)
        set text(size: 1.5em, weight: "bold", fill: white)
        h
      },
    )
  }

  show heading.where(level: 2): set text(size: 1.5em)
  show emph: set text(fill: eastern)

  set-options(..options)

  body
}
