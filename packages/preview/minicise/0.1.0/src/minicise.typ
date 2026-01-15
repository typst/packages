#let sheet(
  title: none,
  document-title: none, // used in header; if none, then is set to title
  course: none,
  semester: none,
  author: none,
  date: none,

  show-header-line: true,

  body
) = {
  let ifnn-line(e) = if e != none [#e \ ]
  let purple = rgb("#555ef0").darken(50%)

  if document-title == none {
      document-title = title
  }

  set par(justify: true)
  set enum(indent: 1em)
  set list(indent: 1em)
  show link: underline
  show link: set text(fill: purple)

  set page(
    margin: (top: 4.5cm, bottom: 3cm),

    header: [
      #set text(size: 0.85em)

      #grid(columns: (40%, 60%),
        align: top,
        [
          #ifnn-line(course)
          #ifnn-line(semester)
        ],
        [
          #show: align.with(top + right)
          #ifnn-line(author)
          #ifnn-line(document-title)
          #ifnn-line(date)
        ]
      )
    ] + if show-header-line {
      v(-0.6em) + line(length: 100%, stroke: 0.4pt)
    },

    footer: {
      set text(size: 0.85em)
      align(center, context {str(counter(page).display())})
    },
  )

  if title != none {
    align(center, text(size: 1.75em, strong(title)))
  }

  body
}

