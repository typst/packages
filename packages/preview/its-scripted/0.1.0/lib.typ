#let screenplay(it, capitalize-headings: true, dir: auto) = context {
  let dir = dir
  if dir == auto {
    dir = text.dir
  }
  if dir != ltr and dir != rtl {
    dir = ltr
  }
  set text(
    size: 12pt,
    font: (
      "Courier",
      "Courier New",
      "DejaVu Sans Mono",
    ),
    dir: dir,
  )
  set page(
    margin: if dir == ltr {
      (
        left: 1.5in,
        right: 1in,
        top: 1in,
        bottom: 1in,
      )
    } else {
      (
        left: 1in,
        right: 1.5in,
        top: 1in,
        bottom: 1in,
      )
    },
    numbering: "1.",
    header: context box(width: 100% + 0.25in)[
      #if page.numbering == none {
        return
      }
      #set align(if dir == ltr { right } else { left })
      #counter(page).display(page.numbering)
    ],
    footer: [],
    header-ascent: 0.25in,
  )
  show heading: set text(size: 12pt)
  show heading: set block(above: 1em, below: 1em)
  show heading: it => {
    if capitalize-headings {
      upper(it)
    } else {
      it
    }
  }
  it
}

#let maketitle(
  title: auto,
  authors: auto,
  date: auto,
  draft: none,
  info: none,
  date-format: "[month repr:long] [day padding:none], [year]",
  ..other,
) = page(
  numbering: none,
  context [
    #let date-format = date-format
    #if type(date-format) != function {
      date-format = date => datetime.display(date, date-format)
    }

    #set align(center + horizon)

    #let title = if title != auto {
      title
      set document(title: title)
    } else if document.title != auto {
      document.title
    } else {
      none
    }
    #if title != none [
      #upper(title)

      #v(2em)
    ]

    #let authors = if authors != auto {
      authors
    } else if document.author.len() > 0 {
      document.author
    } else {
      none
    }
    #if authors != none [
      Written by

      #if type(authors) != array {
        authors
      } else {
        authors.join(parbreak())
      }
      #set document(author: authors)

      #v(2em)
    ]

    #let date = if date != auto {
      date
    } else if document.date != auto {
      document.date
    }
    #if date != none or draft != none [
      #if type(date) != datetime {
        date
      } else {
        date-format(date)
        set document(date: date)
      }

      #if draft != none [
        Draft \##draft
      ]

      #v(2em)
    ]

    #other.pos().join(v(2em))

    #set align(start + bottom)
    #show: block.with(width: 100%, inset: (right: 3in))
    #info
  ],
)

#let _parenthetical-size = state("parenthetical-size", 1);
#let dialog(..args) = {
  let bodies = args.pos()
  if bodies.len() == 1 {
    let (body,) = bodies
    block(
      inset: (
        left: 1.5in,
        right: 1.5in,
        bottom: 0.7em,
        top: 0.7em,
      ),
    )[
      #show heading: set text(weight: "regular")
      #show heading: set block(
        inset: (
          left: 1.2in,
          right: -1.5in,
        ),
      )
      #body
    ]
  } else {
    _parenthetical-size.update(x => x / bodies.len())
    grid(
      columns: (1fr,) * bodies.len(),
      column-gutter: 1.5in / bodies.len(),
      ..bodies.map(body => block(
        inset: (
          bottom: 0.7em,
          top: 0.7em,
        ),
      )[
        #show heading: set text(weight: "regular")
        #show heading: set block(
          inset: (
            left: 1.2in / bodies.len(),
            right: -1.5in / bodies.len(),
          ),
        )
        #body
      ])
    )
    _parenthetical-size.update(x => x * bodies.len())
  }
}
#let parenthetical(body, parens: true) = context block(
  inset: (
    left: 0.7in * _parenthetical-size.get(),
    right: 0.3in * _parenthetical-size.get(),
  ),
  if parens [(#body)] else [#body],
)

#let close(body, capitalize: true) = {
  block(
    inset: (top: 0.7em, bottom: 0.7em),
    width: 100%,
    align(
      center,
      if capitalize {
        upper({
          if type(body) == int [
            end of act #body
          ] else {
            body
          }
        })
      } else {
        if type(body) == int [
          end of act #body
        ] else {
          body
        }
      },
    ),
  )
}
