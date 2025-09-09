#let authors-state = state("authors", (:))
#let show-annotations-state = state("show-annotations", false)
#let page-per-song-state = state("page-per-song", false)
#let is-first-song-state = state("is-first-song", true)

#let songbook(
  title: none,
  songbook-author: none,
  title-page: false,
  settings: (
    paper: "a4",
    font: "Cormorant Garamond",
    title-font: "Cormorant SC",
    text-size: 14pt,
    show-annotations: false,
    page-per-song: false,
    start-right: true,
    index-by-author: false,
    index-by-title: true,
  ),
  body,
) = {
  if title-page {
    assert(title != none, message: "Title should really be set.")
    assert(songbook-author != none, message: "Author should be set.")
  }

  if settings.at("paper", default: none) == none {
    settings.paper = "a4"
  }

  if settings.at("font", default: none) == none {
    settings.font = "Cormorant Garamond"
  }

  if settings.at("title-font", default: none) == none {
    settings.title-font = "Cormorant SC"
  }

  if settings.at("text-size", default: none) == none {
    settings.text-size = 14pt
  }

  if settings.at("show-annotations", default: none) == none {
    settings.show-annotations = false
  }

  if settings.at("page-per-song", default: none) == none {
    settings.page-per-song = false
  }

  if settings.at("start-right", default: none) == none {
    settings.start-right = true
  }

  if settings.at("index-by-author", default: none) == none {
    settings.index-by-author = false
  }

  if settings.at("index-by-title", default: none) == none {
    settings.index-by-title = true
  }

  show-annotations-state.update(settings.show-annotations)
  page-per-song-state.update(settings.page-per-song)

  set page(paper: settings.paper, margin: 2cm)

  set text(font: settings.font, number-type: "lining", size: settings.text-size)

  if title-page {
    context {
      box(width: 70%, [
        #set text(font: "Cormorant SC", size: 36pt)
        *#title*
      ])
    }
    line(length: 80%)
    context {
      set text(size: 24pt)
      songbook-author
    }

    context {
      let authors = authors-state.final()
      if authors.len() != 0 and not (authors.len() == 1 and authors.keys().first() == songbook-author) {
        place(bottom + right)[
          Songs by:\
          #set text(size: 18pt)
          #if authors.len() > 4 {
            let short-authors = ()
            for x in range(0, 4) {
              short-authors += (authors.keys().at(x),)
            }
            [#short-authors.join(", ") and more]
          } else {
            authors.keys().join(", ")
          }
        ]
      }
    }

    context {
      pagebreak(to: if settings.start-right { "odd" } else { none })
      columns(if settings.index-by-author and settings.index-by-title { 2 } else { 1 }, gutter: 1cm)[
        #if settings.index-by-title {
          [*Titles*

          ]
          line(length: 40%)
          set text(size: settings.text-size)
          let titles = ()
          let authors = authors-state.final()
          for author in authors.keys() {
            for song in authors.at(author).songs {
              titles.push((author, song))
            }
          }
          let prev-title-first-char = none
          let sorted-titles = titles.sorted(key: it => lower(it.at(1)))
          for i in range(0, sorted-titles.len()) {
            let curr-title-first-char = lower(str.at(sorted-titles.at(i).at(1), 0))
            if (
              prev-title-first-char == none or curr-title-first-char != prev-title-first-char
            ) {
              prev-title-first-char = lower(str.at(sorted-titles.at(i).at(1), 0))
              [*#upper(prev-title-first-char)*\
              ]
            }
            context {
              [
                #set text(hyphenate: true)
                #sorted-titles.at(i).at(1)
                #set text(size: 11pt, hyphenate: false)
                by #sorted-titles.at(i).at(0)

              ]
            }
          }

          colbreak()
        }

        #if settings.index-by-author {
          [*Artists*

          ]
          line(length: 40%)
          set text(size: settings.text-size)
          let titles = ()
          let authors = authors-state.final()
          for author in authors.keys() {
            for song in authors.at(author).songs {
              titles.push((author, song))
            }
          }
          let prev-title-author-first-char = none
          let sorted-titles = titles.sorted(key: it => lower(it.at(0)))
          for i in range(0, sorted-titles.len()) {
            let curr-title-author-first-char = lower(str.at(sorted-titles.at(i).at(0), 0))
            if (
              prev-title-author-first-char == none or curr-title-author-first-char != prev-title-author-first-char
            ) {
              prev-title-author-first-char = lower(str.at(sorted-titles.at(i).at(0), 0))
              [*#upper(prev-title-author-first-char)*\
              ]
            }
            context {
              [
                #set text(hyphenate: true)
                #sorted-titles.at(i).at(0): #sorted-titles.at(i).at(1)


              ]
            }
          }
        }
      ]
    }
    pagebreak(to: if settings.start-right { "odd" } else { none })
  }

  counter(page).update(1)
  set page(footer: [
    #context {
      if calc.rem(counter(page).get().last(), 2) == 0 {
        place(right, counter(page).display("1/1", both: true))
      } else {
        place(left, counter(page).display("1/1", both: true))
      }
    }
  ])

  body
}

#let author(
  name,
  color: none,
) = {
  (
    name: name,
    color: color,
  )
}

#let annotation(annotation-text, body) = {
  context {
    let show-annotations = show-annotations-state.get()
    box(width: 100% - (if show-annotations { 3em } else { 0pt }), [
      #if show-annotations {
        set text(size: 11pt)
        place(right, dx: 3em, [#annotation-text])
      }
      #body
      \
      \
    ])
  }
}

#let verse(body) = {
  annotation("[Verse]", body)
}

#let bridge(body) = {
  annotation("[Bridge]", body)
}

#let chorus(body) = {
  annotation("[Chorus]", body)
}

#let author-pill(author) = rect(fill: author.at("color", default: none), stroke: none, radius: 4pt, inset: (
  x: 8pt,
  y: 4pt,
))[#author.name]

#let stacked-header(title: none, author: none) = {
  [
    = #title

    #if author != none { align(right, author-pill(author)) }
  ]
}

#let inline-header(title: none, author: none) = {
  [
    #grid(
      columns: (1fr, auto),
      gutter: 12pt,
      [= #title],
      if author != none {
        align(right + bottom)[
          #author-pill(author) ]
      } else { [] },
    )
  ]
}

#let song-header(title: none, author: none) = {
  if title != none {
    rect(
      fill: luma(92%),
      radius: 6pt,
      inset: 8pt,
      if str.len(title) > 38 {
        stacked-header(title: title, author: author)
      } else {
        inline-header(title: title, author: author)
      },
    )
  }
}

#let song(author: none, title: none, body) = {
  context if page-per-song-state.get() and not is-first-song-state.get() {
    pagebreak()
  }

  if type(author) == type("") {
    author = (
      name: author,
      color: none,
    )
  }

  context authors-state.update(authors => {
    if authors.keys().contains(author.name) {
      authors.at(author.name).songs.push(title)
      return authors
    }
    authors.insert(author.name, (songs: (title,)))
    authors
  })

  [
    #song-header(title: title, author: author)

    #body
  ]

  is-first-song-state.update(false)
}

#let set-page-breaking(value) = {
  context page-per-song-state.update(value)
}
